require 'openssl'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :registerable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :two_factor_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
  acts_as_cached

  belongs_to :company

  has_one :employee
  accepts_nested_attributes_for :employee

  has_one_time_password

  # バリデーション
  validates_presence_of :login_id
  validates_uniqueness_of :login_id
  validates_format_of :login_id, :with=>/[a-zA-Z0-9]*/
  validates_format_of :password, :with=>/[!-~]*/
  validates_format_of :google_password, :with=>/[!-~]*/
  validates_format_of :email, :allow_nil=>true, :allow_blank=>true, :with => /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/
  validates_format_of :google_account, :allow_nil=>true, :allow_blank=>true, :with => /[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}/

  before_save :encrypt_password

  has_many :simple_slip_settings, -> { order(:shortcut_key) }
  accepts_nested_attributes_for :simple_slip_settings, :allow_destroy => true

  before_create :set_default_simple_slip_settings

  def has_google_account
    google_account.to_s.size > 0
  end

  # 補助科目として表示する際の名称
  def name
    login_id
  end
  
  def google_password=(value)
    @google_password = value
    # パスワードが更新されたら暗号化パスも初期化
    self.crypted_google_password = ""
  end

  def google_password
    unless self.crypted_google_password.blank? or self.salt.blank?
      @google_password = User.decrypt_password(self.crypted_google_password, self.salt)
    end
    @google_password
  end

  def encrypt_password
    # 既に暗号化済みの場合は何もしない
    if self.crypted_google_password.to_s.size == 0
      self.salt = User.new_salt
      self.crypted_google_password = User.encrypt_password(@google_password, self.salt)
    end
  end

  def need_two_factor_authentication?(request)
    self.use_two_factor_authentication?
  end

  def send_two_factor_authentication_code
    LoginMailer.invoice_login(self).deliver
  end

  private

  # パスワード暗号化
  def self.encrypt_password(password, salt)
    return nil unless password.present?

    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt
    enc.pkcs5_keyivgen(salt)
    return (enc.update(password) + enc.final).unpack("H*")[0]
  end
  
  # パスワード複合化
  def self.decrypt_password(encrypt_password, salt)
    return nil unless encrypt_password.present?
    
    dec = OpenSSL::Cipher::Cipher.new('aes256')
    dec.decrypt
    dec.pkcs5_keyivgen(salt)
    return (dec.update(Array.new([encrypt_password]).pack("H*")) + dec.final)
  end
  
  # 暗号化キーの作成
  def self.new_salt
    s = rand.to_s.tr('+', '.')
    s[0, if s.size > 32 then 32 else s.size end]
  end

  def set_default_simple_slip_settings
    SimpleSlipSetting.set_default_simple_slip_settings(self)
  end
end
