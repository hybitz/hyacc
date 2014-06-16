class Employee < ActiveRecord::Base
  include HyaccErrors
  include HyaccConstants
  
  belongs_to :company
  belongs_to :business_office
  has_many :employee_histories, :dependent=>:destroy
  has_many :users, :dependent=>:destroy
  has_many :branches_employees, :dependent=>:destroy
  has_many :branches, :through=>:branches_employees
  has_many :careers, :dependent=>:destroy

  validates_presence_of :last_name, :first_name
  
  accepts_nested_attributes_for :branches_employees
  accepts_nested_attributes_for :employee_histories

  after_save :reset_account_cache

  # フィールド
  attr_accessor :standard_remuneration # 標準報酬月額
  
  def self.name_is(name)
    where('last_name = ? or first_name = ? or concat(last_name, first_name) = ?', name, name, name)
  end
  
  # デフォルト所属部門
  def default_branch(raise_error = true)
    branches_employee = branches_employees.where(:default_branch => true).first
    return branches_employee.branch if branches_employee

    if raise_error
      raise HyaccException.new(ERR_DEFAULT_BRANCH_NOT_FOUND)
    end
    
    nil
  end

  def default_branch_name
    b = default_branch(false)
    b ? b.name : nil
  end

  def deleted_name
    DELETED_TYPES[deleted]
  end

  def full_name
    last_name + ' ' + first_name
  end
  
  # 補助科目として表示する際の名称
  def name
    full_name
  end
  
  # 扶養家族の人数
  def num_of_dependent(date = nil)
    eh = nil
    if date
      eh = EmployeeHistory.get_at(id, date)
    else
      eh = EmployeeHistory.get_current(id)
    end
  
    eh ? eh.num_of_dependent : 0
  end

  def has_careers
    careers.size > 0
  end
  
  def reset_account_cache
    Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_EMPLOYEE)
  end

  def sex_name
    SEX_TYPES[sex]
  end
  
  def years_of_career
    if has_careers
      min = Career.where(:employee_id => id).order('start_from').first
      max = Career.where(:employee_id => id).order('end_to desc').first

      end_date = Date.today
      end_date = max.end_to if max.end_to < end_date
      end_date.year - min.start_from.year
    else
      0
    end
  end
end
