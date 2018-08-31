class Payroll < ApplicationRecord

  # 相手先伝票区分
  CREDIT_ACCOUNT_TYPE_DEPOSITS_RECEIVED = '0'
  CREDIT_ACCOUNT_TYPE_ADVANCE_MONEY = '1'

  belongs_to :employee
  belongs_to :payroll_journal, class_name: 'Journal', dependent: :destroy, optional: true
  belongs_to :pay_journal, class_name: 'Journal', dependent: :destroy, optional: true
  belongs_to :commission_journal, class_name: 'Journal', dependent: :destroy, optional: true

  validates :employee_id, presence: true
  validates :ym, presence: true
  validates :base_salary, presence: true, numericality: { only_integer: true, greater_than: 0 }
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
                            :allow_nil => true, :message=>"は数値で入力して下さい。"

   before_save :make_journals
                            
  # フィールド
  attr_accessor :insurance_all
  attr_accessor :pension_all
  attr_accessor :transfer_payment      # 振込予定額の一時領域、給与明細と振込み明細の作成時に使用
  attr_accessor :grade                 # 報酬等級

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
    health_insurance + welfare_pension
  end

  # 保険料合計
  def insurance_total
    social_insurance + employment_insurance
  end

  # 保険料控除後の所得
  def after_insurance_deduction
    salary_total - insurance_total
  end

  # 差引合計額（保険料と税金を控除後の金額）
  def after_deduction
    after_insurance_deduction - income_tax - inhabitant_tax
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
    payroll = Payroll.where(ym: ym, employee_id: employee_id, is_bonus: false).first
    payroll ||= Payroll.new(ym: ym, employee_id: employee_id)

    payroll
  end

  # Payrollから賞与情報を取得
  def self.list_bonus(ym_range, employee_id)
    Payroll.where('employee_id = ? and ym >= ? and ym <= ? and is_bonus = ?', employee_id, ym_range.first, ym_range.last, true).order('ym desc')
  end

  # 賃金台帳表示用の賞与情報を取得する
  def self.get_bonus_info(id)
    # 賞与情報を取得
    payroll = Payroll.find(id)
    payroll ||= Payroll.new

    payroll
  end

  def calc_employment_insurance
    ei = TaxUtils.get_employment_insurance(ym)
    self.employment_insurance = (salary_total * ei.employee_general - 0.01).round
  end

  private

  def make_journals
    user = User.find(self.update_user_id)
    param = Auto::Journal::PayrollParam.new(self, user)
    factory = Auto::AutoJournalFactory.get_instance(param)
    journals = factory.make_journals
  
    journals.each do |j|
      begin
        Auto::AutoJournalUtil.do_auto_transfers(j)
        j.save!
      rescue => e
        Rails.logger.warn j.attributes.to_yaml
        Rails.logger.warn j.journal_details.map(&:attributes).to_yaml
        raise e
      end
    end
  
    self.payroll_journal = journals[0]
    self.pay_journal = journals[1]
    self.commission_journal = journals[2]
  end
end
