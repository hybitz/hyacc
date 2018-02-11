class Employee < ApplicationRecord
  include HyaccErrors
  include HyaccConstants
  
  belongs_to :user
  belongs_to :company

  nostalgic_for :num_of_dependent, :zip_code, :address

  validates_presence_of :last_name, :first_name, :birth, :employment_date, :sex
  validates :my_number, :numericality => {:allow_blank => true}

  has_many :branch_employees, :dependent => :destroy
  accepts_nested_attributes_for :branch_employees, :allow_destroy => true

  has_many :branches, :through => :branch_employees
  has_many :careers, -> { order('start_from, end_to') }, :dependent => :destroy

  has_many :exemptions, :dependent => :destroy

  before_validation :set_company_id
  after_save :reset_account_cache

  # フィールド
  attr_accessor :standard_remuneration # 標準報酬月額
  
  def self.name_is(name)
    where('last_name = ? or first_name = ? or concat(last_name, first_name) = ?', name, name, name)
  end
  
  # デフォルト所属部門
  def default_branch(raise_error = true)
    be = branch_employees.where(:default_branch => true).first
    return be.branch if be

    if raise_error
      raise HyaccException.new(ERR_DEFAULT_BRANCH_NOT_FOUND)
    end
    
    nil
  end

  def business_office
    default_branch.business_office
  end

  def default_branch_name
    b = default_branch(false)
    b ? b.name : nil
  end

  def deleted_name
    DELETED_TYPES[deleted]
  end

  def fullname(separetor = ' ')
    last_name + separetor + first_name
  end
  
  # 補助科目として表示する際の名称
  def name
    fullname
  end
  
  def has_careers?
    careers.size > 0
  end
  
  def sex_name
    SEX_TYPES[sex]
  end
  
  def years_of_career
    if has_careers?
      min = Career.where(:employee_id => id).order('start_from').first
      max = Career.where(:employee_id => id).order('end_to desc').first

      end_date = Date.today
      end_date = max.end_to if max.end_to < end_date
      end_date.year - min.start_from.year
    else
      0
    end
  end

  private

  def reset_account_cache
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_EMPLOYEE)
  end

  def set_company_id
    if self.company_id.blank?
      self.company_id = user.company_id
    end
  end

end
