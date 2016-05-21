class SimpleSlipSetting < ActiveRecord::Base
  
  validates :shortcut_key, :format => {:with => /Ctrl\+[0-9]/}
  
  def self.set_default_simple_slip_settings(user)
    user.simple_slip_settings.build(:shortcut_key => 'Ctrl+1', :account => Account.get_by_code(ACCOUNT_CODE_CASH))
    user.simple_slip_settings.build(:shortcut_key => 'Ctrl+2', :account => Account.get_by_code(ACCOUNT_CODE_ORDINARY_DIPOSIT))
    user.simple_slip_settings.build(:shortcut_key => 'Ctrl+3', :account => Account.get_by_code(ACCOUNT_CODE_RECEIVABLE))
  end

  def account
    @account ||= Account.get(account_id)
  end

  def account=(account)
    self.account_id = account.id
    @account = nil
  end

end
