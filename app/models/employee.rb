class Employee < ApplicationRecord
  include HyaccErrors
  include HyaccConstants
  
  belongs_to :company
  belongs_to :user, optional: true

  nostalgic_attr :num_of_dependent, :zip_code, :address

  validates_presence_of :last_name, :first_name, :birth, :employment_date, :sex
  validates :my_number, numericality: {allow_blank: true}

  has_many :branch_employees, -> { where deleted: false }
  accepts_nested_attributes_for :branch_employees

  has_many :branches, through: :branch_employees
  has_many :careers, -> { order('start_from, end_to') }, dependent: :destroy
  has_many :exemptions, dependent: :destroy

  has_one :employee_bank_account
  accepts_nested_attributes_for :employee_bank_account

  has_many :skills, -> {where deleted: false}, inverse_of: 'employee'
  accepts_nested_attributes_for :skills

  def self.name_is(name)
    where('last_name = ? or first_name = ? or concat(last_name, first_name) = ?', name, name, name)
  end
  
  # デフォルト所属部門
  def default_branch(raise_error = true)
    be = branch_employees.where(default_branch: true).first
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
    "#{last_name}#{separetor}#{first_name}"
  end
  
  def fullname_kana(separetor = ' ')
    "#{last_name_kana}#{separetor}#{first_name_kana}"
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

  def calc_payroll_transfer_fee(transfer_amount)
    ret = 500
    return ret if employee_bank_account.nil?
  
    ba = company.bank_account_for_payroll
    if ba.bank_id == employee_bank_account.bank_id
      if ba.bank_office_id == employee_bank_account.bank_office_id
        ret = ba.bank.get_commission(transfer_amount, Bank::TO_SAME_OFFICE)
      else
        ret = ba.bank.get_commission(transfer_amount, Bank::TO_OTHER_OFFICE)
      end
    else
      ret = ba.bank.get_commission(transfer_amount, Bank::TO_OTHER_BANK)
    end
  
    ret || 500
  end

  def qualification_allowance
    if executive
      0
    else
      skills.map(&:qualification).map(&:allowance).reduce(:+)
    end
  end

end
