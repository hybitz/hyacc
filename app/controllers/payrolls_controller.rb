class PayrollsController < Base::HyaccController
  include PayrollHelper

  view_attribute :finder, :class => PayrollFinder, :only => :index
  view_attribute :branches, :only => :index, :include => :deleted
  view_attribute :employees, :only => :index, :scope => :branch

  # 賃金台帳一覧の表示
  def index
    if finder.commit and finder.employee_id > 0
      @employee = Employee.find(finder.employee_id)

      # 標準報酬月額の取得
      ym_range = finder.get_ym_range
      payroll = Payroll.where("employee_id = ? and ym >= ? and ym <= ? and is_bonus = ?", @employee.id, ym_range.first, ym_range.last, false).order("ym desc").first
      @monthly_standard = payroll.monthly_standard if payroll
      @pd = finder.list_monthly_pay
    end
  end

  def new_bonus
    ym = params[:ym]
    employee_id = params[:employee_id]
    previous_payroll = Payroll.get_previous(ym, employee_id)
    raise '前月の給与がない場合の計算には対応していません' unless previous_payroll.present?

    salary = previous_payroll.base_salary
    monthly_standard = previous_payroll.monthly_standard

    @payroll = get_tax(ym, employee_id, salary, 0, 0, 0, monthly_standard, is_bonus: true)
    @payroll.pay_day = get_pay_day(ym, employee_id)
  end

  def new
    ym = params[:ym]
    employee_id = params[:employee_id]

    previous_payroll = Payroll.get_previous(ym, employee_id)
    base_salary = previous_payroll.try(:base_salary).to_i
    extra_pay = previous_payroll.try(:extra_pay).to_i
    commuting_allowance = previous_payroll.try(:commuting_allowance).to_i
    housing_allowance = previous_payroll.try(:housing_allowance).to_i
    monthly_standard = previous_payroll.try(:monthly_standard).to_i

    @payroll = get_tax(ym, employee_id, base_salary, extra_pay, commuting_allowance, housing_allowance, monthly_standard)

    # 初期値の設定
    @payroll.days_of_work = HyaccDateUtil.weekday_of_month(ym.to_i/100, ym.to_i%100)
    @payroll.hours_of_work = @payroll.days_of_work * 8

    # 住民税マスタより住民税額を取得
    @payroll.inhabitant_tax = get_inhabitant_tax(employee_id, ym)
    @payroll.pay_day = get_pay_day(ym, employee_id)
    @payroll.transfer_fee = @payroll.employee.calc_payroll_transfer_fee(base_salary)

    # 従業員への未払費用
    @payroll.accrued_liability = JournalUtil.get_net_sum(current_company.id, ACCOUNT_CODE_UNPAID_EMPLOYEE, nil, employee_id)
  end

  def create
    @payroll = Payroll.new(payroll_params)

    begin
      @payroll.transaction do
        @payroll.save!
      end

      flash[:notice] = "#{@payroll.employee.fullname}さんの#{title}を登録しました。"
      render 'common/reload'

    rescue ActiveRecord::RecordInvalid => e
      handle(e)
      render @payroll.is_bonus? ? 'new_bonus' : 'new'
    end
  end

  def edit
    @payroll = Payroll.find(params[:id])
  end

  def edit_bonus
    @payroll = Payroll.find(params[:id])
  end

  def update
    @payroll = Payroll.find(params[:id])
    @payroll.attributes = payroll_params

    # 削除用に旧伝票を取得
    payroll_on_db = Payroll.find(@payroll.id)
    payroll_journal_on_db = payroll_on_db.payroll_journal
    pay_journal_on_db = payroll_on_db.pay_journal
    commission_journal_on_db = payroll_on_db.commission_journal

    begin
      @payroll.transaction do
        # 給与・支払い伝票は新規追加するので、旧伝票を削除
        Journal.find(payroll_journal_on_db.id).destroy if payroll_journal_on_db
        Journal.find(pay_journal_on_db.id).destroy if pay_journal_on_db
        Journal.find(commission_journal_on_db.id).destroy if commission_journal_on_db

        @payroll.save!
      end

      flash[:notice] = "#{@payroll.employee.fullname}さんの#{title}を更新しました。"
      render 'common/reload'

    rescue ActiveRecord::RecordInvalid => e
      handle(e)
      render @payroll.is_bonus? ? 'edit_bonus' : 'edit'
    end
  end

  def destroy
    @payroll = Payroll.find(params[:id])
    begin
      @payroll.transaction do
        @payroll.destroy
      end

      flash[:notice] = "#{title}を削除しました。"
      render 'common/reload'
    rescue ActiveRecord::RecordInvalid => e
      handle(e)
      render :edit
    end
  end

  # 保険料と厚生年金を自動計算して画面に返却する
  def auto_calc
    # 保険料の検索
    ym = params[:payroll][:ym]
    employee_id = params[:payroll][:employee_id]
    salary = params[:payroll][:base_salary].to_i + params[:payroll][:temporary_salary].to_i 
    extra_pay = params[:payroll][:extra_pay]
    commuting_allowance = params[:payroll][:commuting_allowance]
    housing_allowance = params[:payroll][:housing_allowance]
    monthly_standard = params[:payroll][:monthly_standard]
    is_bonus = params[:payroll][:is_bonus].present?
    payroll = get_tax(ym, employee_id, salary, extra_pay, commuting_allowance, housing_allowance, monthly_standard, is_bonus: is_bonus)

    render json: {
      health_insurance: payroll.health_insurance,
      welfare_pension: payroll.welfare_pension,
      employment_insurance: payroll.employment_insurance,
      income_tax: payroll.income_tax
    }
  end

  # 部門を選択した時に、動的にユーザ選択リストを更新する
  def get_branch_employees
    finder.branch_id = params[:branch_id].to_i

    # 従業員選択用
    branch = Branch.find( finder.branch_id ) unless finder.branch_id == 0
    @employees = branch.employees if branch

    render :partial => 'get_branch_employees'
  end

  private

  def title
    case action_name
    when 'index'
      '賃金台帳'
    else
      '給与明細'
    end
  end

  def payroll_params
    ret = params.require(:payroll).permit(
        :ym, :employee_id, :is_bonus,
        :days_of_work, :hours_of_work, :hours_of_day_off_work, :hours_of_early_work, :hours_of_late_night_work,
        :base_salary, :extra_pay, :temporary_salary, :commuting_allowance, :housing_allowance, :monthly_standard,
        :health_insurance, :welfare_pension, :income_tax, :employment_insurance,
        :inhabitant_tax, :accrued_liability, :annual_adjustment, :pay_day, :transfer_fee)

    case action_name
    when 'create'
      ret.merge!(create_user_id: current_user.id, update_user_id: current_user.id)
    else
      ret.merge!(update_user_id: current_user.id)
    end

    ret
  end

  def get_inhabitant_tax( employee_id, ym )
    inhabitant_tax = InhabitantTax.find_by_employee_id_and_ym(employee_id, ym)
    inhabitant_tax ? inhabitant_tax.amount : 0
  end
end
