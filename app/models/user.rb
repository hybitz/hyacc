class User < ApplicationRecord
  validates :login_id, presence: true, uniqueness: {case_sensitive: false}
  validates_format_of :login_id, with: /\A[a-zA-Z0-9._]+\z/, allow_blank: true

  include DeviseAware

  validates_format_of :password, with: /\A[!-~]*\z/, allow_blank: true  
  validates_format_of :google_account, allow_nil: true, allow_blank: true, with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/

  validates_with Validators::LastActiveAdminValidator

  has_one :employee
  accepts_nested_attributes_for :employee

  has_many :simple_slip_settings, -> { order(:shortcut_key) }
  accepts_nested_attributes_for :simple_slip_settings, allow_destroy: true

  has_many :user_notifications

  scope :active_admins, -> {
    joins(:employee).where(
      admin: true, deleted: false,
      employees: { disabled: false, deleted: false }
    )
  }

  def loginable?(employee_record = nil)
    emp = employee_record || employee
    !deleted? && !emp.disabled? && !emp.deleted?
  end

  def active_admin?
    admin? && loginable?
  end

  def would_remove_last_active_admin?
    was_active = admin_in_database && !deleted_in_database &&
      !employee.deleted_in_database && !employee.disabled_in_database
    return false unless was_active

    will_be_active = admin? && !deleted? && !employee.disabled? && !employee.deleted?
    return false if will_be_active

    company_active_admins = self.class.active_admins.where(employees: { company_id: employee.company_id })
    company_active_admins.where.not(id: id).none?
  end

  def active_for_authentication?
    return false if deleted? || employee.disabled? || employee.deleted?
    super
  end

  def self.from_omniauth(access_token)
    data = access_token.info

    case access_token['provider'].to_sym
    when :google_oauth2
      User.where(google_account: data['email']).first
    else
      nil
    end
  end

  def has_google_account
    google_account.present?
  end

  def code
    login_id
  end

  # 補助科目として表示する際の名称
  def name
    login_id
  end
  
end
