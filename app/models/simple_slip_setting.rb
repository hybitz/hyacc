class SimpleSlipSetting < ActiveRecord::Base
  belongs_to :account

  validates :shortcut_key, :format => {:with => /Ctrl\+[0-9]/}
  
  def self.set_default_simple_slip_settings(user)
    user.simple_slip_settings.build(:shortcut_key => 'Ctrl+1', :account => Account.find_by_code(ACCOUNT_CODE_CASH))
    user.simple_slip_settings.build(:shortcut_key => 'Ctrl+2', :account => Account.find_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT))
    user.simple_slip_settings.build(:shortcut_key => 'Ctrl+3', :account => Account.find_by_code(ACCOUNT_CODE_RECEIVABLE))
  end

end
