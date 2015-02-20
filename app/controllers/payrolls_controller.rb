class PayrollsController < Base::HyaccController
  include PayrollHelper
  include JournalUtil
  
  view_attribute :title => '賃金台帳'
  view_attribute :finder, :class => PayrollFinder, :only => :index
  view_attribute :ym_list, :only => :index
  view_attribute :branches, :only => :index, :include => :deleted
  view_attribute :employees, :only => :index, :scope => :branch

  # 賃金台帳一覧の表示
  def index
    if finder.commit and finder.employee_id > 0
      @employee = Employee.find(finder.employee_id)

      # 標準報酬月額の取得
      ym_range = finder.get_ym_range
      payroll = Payroll.where("employee_id = ? and ym >= ? and ym <= ? and is_bonus = false", @employee.id, ym_range.first, ym_range.last).order("ym desc").first
      ym = payroll.ym if payroll
      base_salary = Payroll.find_by_ym_and_employee_id(ym, @employee.id).base_salary
      
      @employee.standard_remuneration = get_standard_remuneration(ym, @employee.id, base_salary)
      @pd = finder.list_monthly_pay
    end
  end

  def new
    @payroll = Payroll.new.init
    ym = params[:ym]
    # 初期値の設定
    if ym.present?
      @payroll.ym = ym
      @payroll.days_of_work = Date.new(ym.to_i/100, ym.to_i%100, -1).day
      @payroll.hours_of_work = @payroll.days_of_work * 8
      @payroll.base_salary = get_previous_base_salary(ym, finder.employee_id)
      # 住民税マスタより住民税額を取得
      @payroll.inhabitant_tax = get_inhabitant_tax(finder.employee_id, ym)
      @payroll.pay_day = get_pay_day(ym, finder.employee_id).strftime("%Y-%m-%d")
      # 表示対象ユーザID
      @payroll.employee_id = finder.employee_id
      # 従業員への未払費用
      finder = Slips::SlipFinder.new(current_user)
      finder.sub_account_id = finder.employee_id
      finder.account_code = ACCOUNT_CODE_UNPAID_EMPLOYEE
      @payroll.accrued_liability = finder.get_net_sum()
    end
  end
  
  def create
    @payroll = Payroll.new(payroll_params)

    begin
      # 入力チェック
      unless @payroll.validate_params?
        raise ActiveRecord::RecordInvalid.new(@payroll)
      end

      @payroll.transaction do
        make_journals(@payroll)
        @payroll.save!
      end

      flash[:notice] = '賃金台帳情報を登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render 'new'
    end
  end
  
  def edit
    p = Payroll.find(params[:id])
    @payroll = Payroll.find_by_ym_and_employee_id(p.ym, p.employee_id)
  end
  
  def update
    @payroll = Payroll.find(params[:id])
    @payroll.attributes = payroll_params

    # 削除用に旧伝票を取得
    payroll_on_db = Payroll.find(@payroll.id)
    payroll_journal_headers_on_db = payroll_on_db.payroll_journal_headers
    pay_journal_headers_on_db = payroll_on_db.pay_journal_headers

    begin
      # 入力チェック
      unless @payroll.validate_params?
        raise ActiveRecord::RecordInvalid.new(@payroll)
      end

      payroll_on_db.transaction do
        # 給与・支払い伝票は新規追加して旧伝票を削除
        payroll_on_db.days_of_work = @payroll.days_of_work
        payroll_on_db.hours_of_work = @payroll.hours_of_work
        payroll_on_db.hours_of_day_off_work = @payroll.hours_of_day_off_work
        payroll_on_db.hours_of_early_for_work = @payroll.hours_of_early_for_work
        payroll_on_db.hours_of_late_night_work = @payroll.hours_of_late_night_work
        payroll_on_db.credit_account_type_of_insurance = @payroll.credit_account_type_of_insurance
        payroll_on_db.credit_account_type_of_pension = @payroll.credit_account_type_of_pension
        payroll_on_db.credit_account_type_of_income_tax = @payroll.credit_account_type_of_income_tax
        payroll_on_db.credit_account_type_of_inhabitant_tax = @payroll.credit_account_type_of_inhabitant_tax
        
        make_journals(@payroll)
        
        payroll_on_db.payroll_journal_headers = @payroll.payroll_journal_headers
        payroll_on_db.pay_journal_headers = @payroll.pay_journal_headers
        payroll_on_db.save!
        
        JournalHeader.find(payroll_journal_headers_on_db.id).destroy
        JournalHeader.find(pay_journal_headers_on_db.id).destroy
      end

      flash[:notice] = '賃金台帳情報を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render 'edit'
    end
  end

  def destroy
    payroll = Payroll.find(params[:id])
    begin
      payroll.destroy

      flash[:notice] = '賃金台帳情報を削除しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :edit
    end
  end
  
  # 保険料と厚生年金を自動計算して画面に返却する
  def auto_calc
    # 保険料の検索
    ym = params[:payroll][:ym]
    employee_id = params[:payroll][:employee_id]
    base_salary = params[:payroll][:base_salary]
    payroll = get_tax(ym, employee_id, base_salary)

    render :json => {:insurance => payroll.insurance, :pension => payroll.pension, :income_tax => payroll.income_tax}
  end
  
  # 部門を選択した時に、動的にユーザ選択リストを更新する
  def get_branches_employees
    finder.branch_id = params[:branch_id].to_i 

    # 従業員選択用
    branch = Branch.find( finder.branch_id ) unless finder.branch_id == 0
    @employees = branch.employees if branch

    render :partial => 'get_branches_employees'
  end

  private

  def payroll_params
    params.require(:payroll).permit(
        :ym, :employee_id,
        :days_of_work, :hours_of_work, :hours_of_day_off_work, :hours_of_early_for_work, :hours_of_late_night_work,
        :base_salary,
        :insurance, :credit_account_type_of_insurance,
        :pension, :credit_account_type_of_pension,
        :income_tax, :credit_account_type_of_income_tax,
        :inhabitant_tax, :credit_account_type_of_inhabitant_tax,
        :accrued_liability, :year_end_adjustment_liability, :pay_day)
  end

  def make_journals( payroll )
    param = Auto::Journal::PayrollParam.new( payroll, current_user )
    factory = Auto::AutoJournalFactory.get_instance( param )
    journals = factory.make_journals()
    payroll.payroll_journal_headers = journals[0]
    payroll.pay_journal_headers = journals[1]
  end
  
  def get_inhabitant_tax( employee_id, ym )
    inhabitant_tax = InhabitantTax.find_by_employee_id_and_ym(employee_id, ym)
    inhabitant_tax.amount if inhabitant_tax
  end
end
