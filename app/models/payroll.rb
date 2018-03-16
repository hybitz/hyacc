class Payroll < ApplicationRecord

  # 相手先伝票区分
  CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED = '0'
  CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY = '1'

  belongs_to :employee
  belongs_to :payroll_journal_header, :class_name => 'JournalHeader', :dependent => :destroy
  belongs_to :pay_journal_header, :class_name => 'JournalHeader', :dependent => :destroy
  belongs_to :commission_journal_header, :class_name => 'JournalHeader', :dependent => :destroy

  validates_presence_of :employee_id, :ym, :message => "は必須です。"
  validates :base_salary, :presence => true, numericality: { only_integer: true, greater_than: 0 }
  validates :commuting_allowance, :presence => true, numericality: { only_integer: true, greater_than_equal: 0, allow_blank: true}
  validates :annual_adjustment, numericality: { only_integer: true, allow_blank: true }
  validates_numericality_of :days_of_work, :hours_of_work,
                            :hours_of_day_off_work, :hours_of_early_work,
                            :hours_of_late_night_work,
                            :allow_nil => true, :message=>"は数値で入力して下さい。"

  # フィールド
  attr_accessor :income_tax     # 源泉所得税
  attr_accessor :insurance      # 個人負担保険料
  attr_accessor :pension        # 個人負担保険料
  attr_accessor :employment_insurance # 被雇用者負担雇用保険料
  attr_accessor :insurance_all
  attr_accessor :pension_all
  attr_accessor :pay_day
  attr_accessor :is_new
  attr_accessor :inhabitant_tax        # 住民税
  attr_accessor :transfer_payment      # 振込予定額の一時領域、給与明細と振込み明細の作成時に使用
  attr_accessor :grade                 # 報酬等級
  attr_accessor :accrued_liability     # 従業員への未払費用

  def initialize( args = nil )
    super( args )
    @is_new = true
  end

  def init
    @income_tax = 0
    @insurance = 0
    @pension = 0
    @employment_insurance = 0
    @insurance_all = 0
    @pension_all = 0
    @inhabitant_tax = 0
    @grade = 0
    @accrued_liability = 0
    self
  end

  # 給与小計
  def salary_subtotal
    base_salary + commuting_allowance
  end

  # 給与合計
  def salary_total
    salary_subtotal
  end

  # 社会保険料（健康保険＋厚生年金）
  def social_insurance
    insurance + pension
  end

  # 社会保険料、雇用保険料控除後の所得
  def after_insurance_deduction
    salary_total - social_insurance - employment_insurance
  end

  # 差引合計額（保険料と税金を控除後の金額）
  def after_deduction
    after_insurance_deduction - income_tax - inhabitant_tax
  end

  def validate_params?
    result = true
    unless insurance =~ /^[0-9]{1,}$/
      errors.add(:insurance, "は数値で入力して下さい。")
      result = false
    end
    unless pension =~ /^[0-9]{1,}$/
      errors.add(:pension, "は数値で入力して下さい。")
      result = false
    end
    unless income_tax =~ /^[0-9]{1,}$/
      errors.add(:income_tax, "は数値で入力して下さい。")
      result = false
    end
    unless inhabitant_tax =~ /^[0-9]{1,}$/
      errors.add(:inhabitant_tax, "は数値で入力して下さい。")
      result = false
    end
    unless accrued_liability =~ /^[0-9]{1,}$/
      errors.add(:accrued_liability, "は数値で入力して下さい。")
      result = false
    end

    if pay_day =~ /^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$/
      split = pay_day.split('-').map(&:to_i)
      unless Date.valid_date?(split[0], split[1], split[2])
        errors.add(:pay_day, "は存在する日付をYYYY-MM-DD形式で入力して下さい。")
        result = false
      end
    else
      errors.add(:pay_day, "はYYYY-MM-DD形式で入力して下さい。")
      result = false
    end
    return result
  end

  def self.get_previous_base_salary(ym, employee_id)
    ret = 0
    # 前月分を検索
    past_ym = ym.to_i - 1
    # 1月の場合、-1年(-100)+11月
    past_ym = ym.to_i - 89 if ym.to_i%100 == 1
    previous_payroll = Payroll.where(:ym => past_ym, :employee_id => employee_id, :is_bonus => false).order('ym').first
    if previous_payroll
      ret = previous_payroll.base_salary
    end
    ret
  end

  def self.find_by_ym_and_employee_id(ym, employee_id)
    # 月別情報を検索
    payroll = Payroll.where(:ym => ym, :employee_id => employee_id, :is_bonus => false).first
    return Payroll.new.init unless payroll

    # アディショナル項目を初期値にセット
    payroll.init
    # 給与伝票取得
    payroll.income_tax = payroll.get_income_tax_from_jd
    payroll.insurance = payroll.get_insurance_from_jd
    payroll.pension = payroll.get_pension_from_jd
    payroll.employment_insurance = payroll.get_employment_insurance_from_jd
    payroll.inhabitant_tax = payroll.get_inhabitant_tax_from_jd

    # 支払の伝票取得
    if payroll.pay_journal_header != nil
      jh = payroll.pay_journal_header
      payroll.pay_day = Date.new(jh.ym/100, jh.ym%100, jh.day).strftime("%Y-%m-%d")
      payroll.accrued_liability = payroll.get_accrued_liability_from_jd
    end

    # 編集フラグをセット　※Viewで使用
    payroll.is_new = false

    payroll
  end

  # Payrollから賞与情報を取得
  def self.list_bonus(ym_range, employee_id)
    Payroll.where('employee_id = ? and ym >= ? and ym <= ? and is_bonus = ?', employee_id, ym_range.shift, ym_range.pop, true).order('ym desc')
  end

  # 賃金台帳表示用の賞与情報を取得する
  def self.get_bonus_info(id)
    # 賞与情報を取得
    payroll = Payroll.find(id)
    if payroll == nil
      return Payroll.new.init
    end
    # アディショナル項目を初期値にセット
    payroll.init
    # 給与伝票取得
    payroll.income_tax = payroll.get_income_tax_from_jd
    payroll.insurance = payroll.get_insurance_from_jd
    payroll.pension = payroll.get_pension_from_jd
    payroll.employment_insurance = payroll.get_employment_insurance_from_jd

    # 支払の伝票取得
    if payroll.pay_journal_header != nil
      jh = payroll.pay_journal_header
      payroll.pay_day = Date.new(jh.ym/100, jh.ym%100, jh.day).strftime("%Y-%m-%d")
      payroll.accrued_liability = payroll.get_accrued_liability_from_jd
    end

    # 編集フラグをセット　※Viewで使用
    payroll.is_new = false

    payroll
  end

  # 仕訳明細から源泉所得税金額を取得する
  def get_income_tax_from_jd
    if self.credit_account_type_of_income_tax == CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_INCOME_TAX)
    elsif self.credit_account_type_of_income_tax == CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_INCOME_TAX)
    end
  end

  # 仕訳明細から健康保険料を取得する
  def get_insurance_from_jd
    if self.credit_account_type_of_insurance == CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    elsif self.credit_account_type_of_insurance == CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_HEALTH_INSURANCE)
    end
  end

  # 仕訳明細から厚生年金を取得する
  def get_pension_from_jd
    if self.credit_account_type_of_pension == CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_EMPLOYEES_PENSION)
    elsif self.credit_account_type_of_pension == CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_EMPLOYEES_PENSION)
    end
  end

  # 仕訳明細から雇用保険を取得する
  def get_employment_insurance_from_jd
    case self.credit_account_type_of_employment_insurance
    when CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_EMPLOYMENT_INSURANCE)
    when CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_EMPLOYMENT_INSURANCE)
    else
      raise "不正な勘定科目です。credit_account_type_of_employment_insuranceA=#{credit_account_type_of_employment_insurance}"
    end
  end

  # 仕訳明細から住民税を取得する
  def get_inhabitant_tax_from_jd
    if self.credit_account_type_of_inhabitant_tax == CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_DEPOSITS_RECEIVED, SUB_ACCOUNT_CODE_INHABITANT_TAX)
    elsif self.credit_account_type_of_inhabitant_tax == CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY
      return payroll_journal_header.get_credit_amount(ACCOUNT_CODE_ADVANCE_MONEY, SUB_ACCOUNT_CODE_INHABITANT_TAX)
    end
  end

  # 仕訳明細から未払費用を取得する
  def get_accrued_liability_from_jd
    payroll_journal_header.get_debit_amount(ACCOUNT_CODE_UNPAID_EMPLOYEE)
  end

  def calc_employment_insurance
    # 対象月の末日を基準
    date = Date.new(ym.to_i/100, ym.to_i%100, -1)

    ei = TaxJp::LaborInsurances::EmploymentInsurance.find_by_date(date)
    self.employment_insurance = (salary_total * ei.employee_general - 0.01).round
  end
end
