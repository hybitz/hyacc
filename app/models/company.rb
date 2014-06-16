class Company < ActiveRecord::Base
  include HyaccConstants
  
  belongs_to :business_type
  has_many :branches
  has_many :business_offices
  has_many :users
  has_many :fiscal_years
  
  file_column :logo_path, :web_root => "system/app_files/", :root_path => File.join(Rails.root, "public", "system", "app_files")

  validates_presence_of :name, :founded_date
  validates_format_of :admin_email, :allow_nil=>true, :allow_blank=>true, :with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

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
  
  # 本部を取得する
  def get_head_office
    head_office = Branch.find(:all, :conditions=>["company_id=? and is_head_office=?", id, true])
    raise HyaccException.new(HyaccErrors::ERR_ILLEGAL_STATE) unless head_office.length == 1
    head_office[0]
  end

  # 本社を取得する
  def get_head_business_office
    head_business_office = BusinessOffice.find(:all, :conditions=>["company_id=? and is_head=?", id, true])
    raise HyaccException.new(HyaccErrors::ERR_ILLEGAL_STATE) unless head_business_office.length == 1
    head_business_office[0]
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
