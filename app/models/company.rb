class Company < ActiveRecord::Base
  include HyaccConstants
  
  belongs_to :business_type
  has_many :branches
  has_many :business_offices
  has_many :users
  has_many :fiscal_years
  
  mount_uploader :logo, LogoUploader

  validates_presence_of :name, :founded_date
  validates_format_of :admin_email, :allow_nil=>true, :allow_blank=>true, :with => /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/

  def current_fiscal_year
    fiscal_years.where(:fiscal_year => fiscal_year).first
  end
  
  def current_fiscal_year_int
    current_fiscal_year.fiscal_year
  end
  
  def founded_fiscal_year
    get_fiscal_year( founded_date.year * 100 + founded_date.month )
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

  def new_fiscal_year
    ret = FiscalYear.new(:company_id => self.id)
    ret.fiscal_year = last_fiscal_year.fiscal_year + 1
    ret.tax_management_type = last_fiscal_year.tax_management_type
    ret.consumption_entry_type = last_fiscal_year.consumption_entry_type
    ret.closing_status = CLOSING_STATUS_OPEN
    ret
  end

  # 本部を取得する
  def get_head_office
    head_office = Branch.where(:company_id => id, :is_head_office => true)
    raise HyaccException.new(HyaccErrors::ERR_ILLEGAL_STATE) unless head_office.count == 1
    head_office.first
  end

  # 本社を取得する
  def get_head_business_office
    head_business_office = BusinessOffice.where(:company_id => id, :is_head => true)
    raise HyaccException.new(HyaccErrors::ERR_ILLEGAL_STATE) unless head_business_office.count == 1
    head_business_office.first
  end

  # 個人事業主かどうか
  def type_of_personal
    type_of == COMPANY_TYPE_PERSONAL
  end
  
  def company_type_name
    COMPANY_TYPES[type_of]
  end
  
  def business_type_name
    return nil unless business_type_id
    business_type.name
  end
end
