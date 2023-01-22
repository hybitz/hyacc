class User < ApplicationRecord
  devise :database_authenticatable, :two_factor_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  has_one :employee
  accepts_nested_attributes_for :employee

  has_one_time_password

  validates :login_id, presence: true, uniqueness: true
  validates_format_of :login_id, :with=>/\A[a-zA-Z0-9._]+\z/
  validates_format_of :password, :with=>/\A[!-~]*\z/
  validates_format_of :email, allow_nil: true, allow_blank: true, with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/
  validates_format_of :google_account, allow_nil: true, allow_blank: true, with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/

  has_many :simple_slip_settings, -> { order(:shortcut_key) }
  accepts_nested_attributes_for :simple_slip_settings, allow_destroy: true

  def self.from_omniauth(access_token)
    data = access_token.info

    case access_token['provider'].to_sym
    when :google_oauth2
      User.where(:google_account => data["email"]).first
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
  
  def need_two_factor_authentication?(request)
    self.use_two_factor_authentication?
  end

  def send_two_factor_authentication_code(code)
    LoginMailer.invoice_login(self).deliver_now
  end

end
