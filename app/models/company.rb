class Company < ApplicationRecord
  belongs_to :business_type, optional: true
  has_many :branches, -> { where deleted: false }

  has_many :business_offices, -> { where deleted: false }, inverse_of: 'company'
  accepts_nested_attributes_for :business_offices

  has_many :employees, -> { where deleted: false }
  has_many :users, through: 'employees'
  has_many :fiscal_years, -> { where deleted: false }

  validates :name, presence: true
  validates :founded_date, presence: true
  validates :admin_email, email: {allow_blank: true}
  validates :enterprise_number, numericality: {allow_blank: true}
  validates :labor_insurance_number, numericality: {allow_blank: true}, length: {is: 14, allow_blank: true}
  validates :retirement_savings_after, numericality: {allow_blank: true, only_integer: true, greater_than_or_equal_to: 1}

  mount_uploader :logo, LogoUploader

  has_many :banks, -> { where deleted: false }
  has_many :bank_accounts, -> { where deleted: false }

  has_many :qualifications, -> { where deleted: false }, inverse_of: 'company'

  has_many :journals, -> { where deleted: false }

  attr_accessor :day_of_payday
  attr_accessor :month_of_payday

  after_initialize :load_payday

  def bank_account_for_payroll
    bank_accounts.find_by(for_payroll: true)
  end
  
  def current_fiscal_year
    fiscal_years.where(fiscal_year: fiscal_year).first
  end

  def current_fiscal_year_int
    current_fiscal_year.fiscal_year
  end

  def founded_fiscal_year
    get_fiscal_year(founded_year_month)
  end

  def founded_year_month
    founded_date.year * 100 + founded_date.month
  end

  def last_fiscal_year
    fiscal_years.order("fiscal_year desc").first
  end

  def get_fiscal_year(yyyymmORyyyy)
    if yyyymmORyyyy > 10000
      yyyy = get_fiscal_year_int(yyyymmORyyyy)
    else
      yyyy = yyyymmORyyyy
    end

    fiscal_years.where(fiscal_year: yyyy).first
  end

  def get_fiscal_year_int( ym )
    year = ym.to_i / 100
    month = ym.to_i % 100

    # 年度開始月が年の後半の場合
    if start_month_of_fiscal_year >= 7
      if month >= start_month_of_fiscal_year
        year + 1
      else
        year
      end
    # 年度開始月が年の前半の場合
    else
      if month < start_month_of_fiscal_year
        year - 1
      else
        year
      end
    end
  end

  # 税抜経理方式の場合は、勘定科目の税区分を取得
  # それ以外は、非課税をデフォルトとする
  def get_tax_type_for(account)
    ret = TAX_TYPE_NONTAXABLE

    if current_fiscal_year.tax_exclusive?
      ret= account.tax_type
    end

    ret
  end

  def new_fiscal_year
    ret = fiscal_years.build
    ret.fiscal_year = last_fiscal_year.fiscal_year + 1
    ret.tax_management_type = last_fiscal_year.tax_management_type
    ret.consumption_entry_type = last_fiscal_year.consumption_entry_type
    ret.closing_status = CLOSING_STATUS_OPEN
    ret
  end

  # 本店部門を取得する
  def head_branch
    branches.where('parent_id is null').first!
  end

  # 個人事業主かどうか
  def personal?
    type_of == COMPANY_TYPE_PERSONAL
  end

  def company_type_name
    COMPANY_TYPES[type_of]
  end

  def business_type_name
    return nil unless business_type_id
    business_type.name
  end

  def employment_insurance_type_name
    TaxJp::EMPLOYMENT_INSURANCE_TYPES[employment_insurance_type]
  end

  def retirement_savings_after_jp
    return nil unless retirement_savings_after
    "入社#{retirement_savings_after}年目から"
  end

  def tax_inclusive?
    current_fiscal_year.tax_management_type == TAX_MANAGEMENT_TYPE_INCLUSIVE
  end

  def tax_exclusive?
    current_fiscal_year.tax_management_type == TAX_MANAGEMENT_TYPE_EXCLUSIVE
  end

  def tax_general?
    current_fiscal_year.consumption_entry_type == CONSUMPTION_ENTRY_TYPE_GENERAL
  end

  def tax_simplified?
    current_fiscal_year.consumption_entry_type == CONSUMPTION_ENTRY_TYPE_SIMPLIFIED
  end

  def payday_jp
    pd = self.payday
    pd = DEFAULT_PAYDAY if pd.blank?

    month, day = pd.split(',')

    case month.to_i
    when 0
      month_jp = '当月'
    when 1
      month_jp = '翌月'
    when 2
      month_jp = '翌々月'
    else
      month_jp = "#{month}ヶ月後"
    end

    return "#{month_jp}#{day || 25}日"
  end

  def payroll_day(ym)
    if month_of_payday == 0
      day_of_payday
    else
      Date.new(ym/100, ym%100, -1).day
    end
  end

  def get_actual_pay_day_for(ym)
    ret = Date.new(ym.to_i/100, ym.to_i%100, day_of_payday)
    ret = ret >> month_of_payday

    # 土日だったら休日前支払
    while !HyaccDateUtil.weekday?(ret)
      ret = ret - 1
    end

    ret
  end

  private

  def load_payday
    pd = self.payday
    pd = DEFAULT_PAYDAY if pd.blank?

    month, day = pd.split(",")
    self.month_of_payday = month.to_i
    self.day_of_payday = day.to_i > 0 ? day.to_i : 25
  end

end
