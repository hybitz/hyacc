class Company < ActiveRecord::Base
  belongs_to :business_type
  has_many :branches

  has_many :business_offices, :inverse_of => 'company'
  accepts_nested_attributes_for :business_offices

  has_many :users
  has_many :employees
  has_many :fiscal_years

  mount_uploader :logo, LogoUploader

  validates_presence_of :name, :founded_date
  validates_format_of :admin_email, :allow_nil => true, :allow_blank => true, :with => /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/

  attr_accessor :day_of_payday
  attr_accessor :month_of_payday

  after_initialize :load_payday

  def current_fiscal_year
    fiscal_years.where(:fiscal_year => fiscal_year).first
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

  def get_fiscal_year( yyyymmORyyyy )
    if yyyymmORyyyy > 10000
      yyyy = get_fiscal_year_int( yyyymmORyyyy )
    else
      yyyy = yyyymmORyyyy
    end

    fiscal_years.where(:fiscal_year => yyyy).first
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
    ret = TAX_MANAGEMENT_TYPE_EXEMPT

    if current_fiscal_year.tax_exclusive?
      ret= account.tax_type
    end

    ret
  end

  def new_fiscal_year
    ret = FiscalYear.new(:company_id => self.id)
    ret.fiscal_year = last_fiscal_year.fiscal_year + 1
    ret.tax_management_type = last_fiscal_year.tax_management_type
    ret.consumption_entry_type = last_fiscal_year.consumption_entry_type
    ret.closing_status = CLOSING_STATUS_OPEN
    ret
  end

  # 部門ありモードかどうか
  def branch_mode
    branches.where(:deleted => false).size > 1
  end

  # 本店部門を取得する
  def get_head_branch
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
    while ret.wday == 0 or ret.wday == 6
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
