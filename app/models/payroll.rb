class Payroll < ApplicationRecord
  belongs_to :employee

  validates :employee_id, presence: true
  validates :ym, presence: true
  validates :base_salary, presence: true, numericality: { only_integer: true, greater_than: 0 }, :unless => :is_bonus?
  validates :temporary_salary, presence: true, numericality: { only_integer: true, greater_than: 0 }, :if => :is_bonus?
  validates :commuting_allowance, presence: true, numericality: { only_integer: true, greater_than_equal: 0, allow_blank: true}
  validates :health_insurance, presence: true, numericality: { only_integer: true, greater_than_equal: 0, allow_blank: true}
  validates :welfare_pension, presence: true, numericality: { only_integer: true, greater_than_equal: 0, allow_blank: true}
  validates :income_tax, presence: true, numericality: { only_integer: true, greater_than_equal: 0, allow_blank: true}
  validates :inhabitant_tax, presence: true, numericality: { only_integer: true, greater_than_equal: 0, allow_blank: true}
  validates :annual_adjustment, numericality: { only_integer: true, allow_blank: true }
  validates :accrued_liability, numericality: { only_integer: true, allow_blank: true }
  validates :pay_day, date: true

  validates_numericality_of :days_of_work, :hours_of_work,
                            :hours_of_day_off_work, :hours_of_early_work,
                            :hours_of_late_night_work,
                            allow_nil: true, message: "は数値で入力して下さい。"

  has_one :payroll_journal, class_name: 'Auto::Journal::Payroll', dependent: :destroy
  has_one :pay_journal, class_name: 'Auto::Journal::PayrollPay', dependent: :destroy
  has_one :commission_journal, class_name: 'Auto::Journal::PayrollCommission', dependent: :destroy

  before_save :make_journals
                            
  # フィールド
  attr_accessor :transfer_payment      # 振込予定額の一時領域、給与明細と振込み明細の作成時に使用
  attr_accessor :grade                 # 報酬等級

  def year
    ym / 100
  end

  def month
    ym % 100
  end

  def monthly_pay?
    !is_bonus?
  end

  # 給与小計
  def salary_subtotal
    base_salary + extra_pay + commuting_allowance + housing_allowance + qualification_allowance
  end

  # 給与合計
  def salary_total
    salary_subtotal + temporary_salary
  end

  # 社会保険料（健康保険＋厚生年金）
  def social_insurance
    health_insurance + welfare_pension
  end

  # 保険料合計（社会保険＋雇用保険）
  def insurance_total
    social_insurance + employment_insurance
  end

  # 保険料控除後の所得
  def after_insurance_deduction
    salary_total - insurance_total
  end

  # 差引支給額（保険料と税金を控除後の金額）
  def after_deduction
    after_insurance_deduction - income_tax - inhabitant_tax
  end

  # 差引合計額
  def pay_total
    after_deduction + annual_adjustment + accrued_liability + misc_adjustment
  end

  def self.get_previous(ym, employee_id)
    # 前月分を検索
    past_ym = ym.to_i - 1
    # 1月の場合、-1年(-100)+11月
    past_ym = ym.to_i - 89 if ym.to_i%100 == 1

    Payroll.where(ym: past_ym, employee_id: employee_id, is_bonus: false).first
  end

  def self.find_by_ym_and_employee_id(ym, employee_id)
    # 月別情報を検索
    payroll = Payroll.where(ym: ym, employee_id: employee_id, is_bonus: false).first
    payroll ||= Payroll.new(ym: ym, employee_id: employee_id)

    payroll
  end

  # 賞与
  def self.list_bonus(ym_range, employee_id)
    Payroll.where('employee_id = ? and ym >= ? and ym <= ? and is_bonus = ?', employee_id, ym_range.first, ym_range.last, true)
  end

  # 扶養親族の数
  def num_of_dependent
    raise '先に給与明細の年月が確定している必要があります' if ym.to_i == 0

    date = Date.new(ym / 100, ym % 100, -1) # 対象月の末日を基準に徴収する
    employee.num_of_dependent_on(date)
  end
  
  # 月給の社会保険料は、標準報酬月額を基準に計算
  # 賞与の社会保険料は、支給額に率を掛けて計算
  def calc_social_insurance
    # 事業主が、給与から被保険者負担分を控除する場合、被保険者負担分の端数が50銭以下の場合は切り捨て、50銭を超える場合は切り上げて1円となる
    # 折半額の端数は個人負担
    if care_applicable?
      self.health_insurance = (health_insurance_model.health_insurance_half_care - 0.01).round
    else
      self.health_insurance = (health_insurance_model.health_insurance_half - 0.01).round
    end
    self.welfare_pension = (welfare_pension_model.welfare_pension_insurance_half - 0.01).round
  end

  def calc_employment_insurance
    if employee.executive?
      self.employment_insurance = 0
    else
      ei = TaxUtils.get_employment_insurance(ym)
      self.employment_insurance = (salary_total * ei.employee_general - 0.01).round
    end
  end
  
  def calc_income_tax
    date = Date.new(ym.to_i/100, ym.to_i%100, -1) # 対象月の末日を基準
    salary = salary_total - insurance_total - commuting_allowance

    if is_bonus?
      previous = self.class.get_previous(ym, employee_id)
      previous_salary = previous.salary_total - previous.insurance_total - previous.commuting_allowance
      tax_ratio = WithheldTax.find_bonus_tax_ratio_by_date_and_salary_and_dependent(date, previous_salary, num_of_dependent)
      self.income_tax = (salary * tax_ratio).to_i
    else
      self.income_tax = WithheldTax.find_by_date_and_salary_and_dependent(date, salary, num_of_dependent)
    end
  end

  # 介護保険は40歳の誕生日前日の月から65歳の誕生日前日の月の前月までが対象
  def care_applicable?
    care_from = (employee.birth + 40.years - 1.day).strftime("%Y%m").to_i 
    care_to = (employee.birth + 65.years - 1.day).strftime("%Y%m").to_i 
    ym >= care_from && ym < care_to
  end
  
  def health_insurance_all
    if care_applicable?
      health_insurance_model.health_insurance_all_care.truncate
    else
      health_insurance_model.health_insurance_all.truncate
    end
  end
  
  def pension_all
    welfare_pension_model.welfare_pension_insurance_all.truncate
  end

  def journaled_health_insurance_company
    if @_journaled_health_insurance_company.nil?
      jd = find_payroll_journal_detail(ACCOUNT_CODE_LEGAL_WELFARE, TAX_DEDUCTION_TYPE_HEALTH_INSURANCE)
      @_journaled_health_insurance_company = jd&.amount || 0
    end

    @_journaled_health_insurance_company
  end

  def journaled_health_insurance_employee
    if @_journaled_health_insurance_employee.nil?
      jd = find_payroll_journal_detail(ACCOUNT_CODE_DEPOSITS_RECEIVED, TAX_DEDUCTION_TYPE_HEALTH_INSURANCE)
      @_journaled_health_insurance_employee = jd&.amount || 0
    end

    @_journaled_health_insurance_employee
  end

  def journaled_welfare_pension_company
    if @_journaled_welfare_pension_company.nil?
      jd = find_payroll_journal_detail(ACCOUNT_CODE_LEGAL_WELFARE, TAX_DEDUCTION_TYPE_WELFARE_PENSION)
      @_journaled_welfare_pension_company = jd&.amount || 0
    end

    @_journaled_welfare_pension_company
  end

  def journaled_welfare_pension_employee
    if @_journaled_welfare_pension_employee.nil?
      jd = find_payroll_journal_detail(ACCOUNT_CODE_DEPOSITS_RECEIVED, TAX_DEDUCTION_TYPE_WELFARE_PENSION)
      @_journaled_welfare_pension_employee = jd&.amount || 0
    end
    @_journaled_welfare_pension_employee
  end

  private

  def find_payroll_journal_detail(account_code, sub_account_code)
    payroll_journal.journal_details.find{|jd| jd.account.code == account_code and jd.sub_account.code == sub_account_code }
  end

  # 事業所の都道府県コード
  def prefecture_code
    employee.business_office.prefecture_code
  end

  def base_bonus_salary_for_insurance
    salary_total - (salary_total % 1000)
  end
  
  def social_insurance_model
    if @social_insurance_model.nil?
      @social_insurance_model = TaxUtils.get_social_insurance(ym, prefecture_code, monthly_standard)
    end
    @social_insurance_model
  end
  
  def health_insurance_model
    if @health_insurance_model.nil?
      if is_bonus?
        @health_insurance_model = TaxUtils.get_health_insurance(ym, prefecture_code, base_bonus_salary_for_insurance)
      else
        @health_insurance_model = social_insurance_model
      end
    end
    @health_insurance_model
  end

  def welfare_pension_model
    if @welfare_pension_model.nil?
      if is_bonus?
        @welfare_pension_model = TaxUtils.get_welfare_pension(ym, base_bonus_salary_for_insurance)
      else
        @welfare_pension_model = social_insurance_model
      end
    end
    @welfare_pension_model
  end

  def make_journals
    user = User.find(self.update_user_id)
    param = Auto::Journal::PayrollParam.new(self, user)
    factory = Auto::AutoJournalFactory.get_instance(param)
    journals = factory.make_journals
  
    journals.each do |j|
      begin
        Auto::AutoJournalUtil.do_auto_transfers(j)
      rescue => e
        Rails.logger.warn j.attributes.to_yaml
        Rails.logger.warn j.journal_details.map(&:attributes).to_yaml
        raise e
      end
    end
  end
end
