class Hr::PayrollsController < Base::HyaccController
  include Hr::PayrollHelper

  view_attribute :finder, class: PayrollFinder, only: :index
  view_attribute :branches, only: :index, include: :deleted

  # 賃金台帳一覧の表示
  def index
    @employees = load_employees(finder.fiscal_year, finder.branch_id)

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
    @payroll = get_tax(ym, employee_id, monthly_standard, salary, 0, 0, 0, is_bonus: true)
  end

  def new
    ym = params[:ym]
    employee = current_company.employees.find(params[:employee_id])

    previous_payroll = Payroll.get_previous(ym, employee.id)
    monthly_standard = previous_payroll.try(:monthly_standard).to_i
    salary = previous_payroll.try(:base_salary).to_i
    commuting_allowance = previous_payroll.try(:commuting_allowance).to_i
    housing_allowance = previous_payroll.try(:housing_allowance).to_i
    qualification_allowance = employee.qualification_allowance

    @payroll = get_tax(ym, employee.id, monthly_standard, salary, commuting_allowance, housing_allowance, qualification_allowance)

    # 初期値の設定
    @payroll.days_of_work = HyaccDateUtil.weekday_of_month(ym.to_i/100, ym.to_i%100)
    @payroll.hours_of_work = @payroll.days_of_work * 8

    # 住民税マスタより住民税額を取得
    @payroll.inhabitant_tax = get_inhabitant_tax(employee.id, ym)

    # 従業員への未払費用
    @payroll.accrued_liability = JournalUtil.get_net_sum(current_company.id, ACCOUNT_CODE_UNPAID_EMPLOYEE, nil, employee.id)
    
    # 振込手数料の想定額
    @payroll.transfer_fee = @payroll.employee.calc_payroll_transfer_fee(@payroll.pay_total)
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
    monthly_standard = params[:payroll][:monthly_standard]
    salary = params[:payroll][:base_salary].to_i + params[:payroll][:temporary_salary].to_i + params[:payroll][:extra_pay].to_i
    commuting_allowance = params[:payroll][:commuting_allowance]
    housing_allowance = params[:payroll][:housing_allowance]
    qualification_allowance = params[:payroll][:qualification_allowance]
    pay_day = params[:payroll][:pay_day]
    is_bonus = params[:payroll][:is_bonus].present?
    payroll = get_tax(ym, employee_id, monthly_standard, salary, commuting_allowance, housing_allowance, qualification_allowance, pay_day: pay_day, is_bonus: is_bonus)

    render json: {
      health_insurance: payroll.health_insurance,
      welfare_pension: payroll.welfare_pension,
      employment_insurance: payroll.employment_insurance,
      income_tax: payroll.income_tax
    }
  end

  # 部門を選択した時に、動的にユーザ選択リストを更新する
  def get_branch_employees
    @employees = load_employees(params[:fiscal_year], params[:branch_id])
    render partial: 'get_branch_employees'
  end

  private

  # 従業員選択用リスト
  def load_employees(fiscal_year, branch_id)
    branch = Branch.find_by(id: branch_id.to_i)
    ret = branch&.employees
    
    fiscal_year = current_company.fiscal_years.find_by(fiscal_year: fiscal_year.to_i)
    ret = ret.where('employment_date <= ? and (retirement_date is null or retirement_date >= ?)', fiscal_year.end_day, fiscal_year.start_day)
  end

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
        :base_salary, :extra_pay, :temporary_salary, :commuting_allowance, :housing_allowance, :qualification_allowance, :monthly_standard,
        :health_insurance, :welfare_pension, :income_tax, :employment_insurance, :inhabitant_tax,
        :accrued_liability, :annual_adjustment, :misc_adjustment, :misc_adjustment_note, :pay_day, :transfer_fee)

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
