class Update1881OnAccounts < ActiveRecord::Migration[7.2]
  include HyaccConst

  def up
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT)
    return unless a
    a.is_temporary_payment_account = true
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_TEMPORARY_PAYMENT)
    return unless a
    a.is_temporary_payment_account = false
    a.save!
  end
end

