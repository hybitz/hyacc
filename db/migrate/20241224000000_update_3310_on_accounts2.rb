class Update3310OnAccounts2 < ActiveRecord::Migration[6.1]
  include HyaccConst

  def up
    a = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT)
    return unless a
    a.sub_account_type = SUB_ACCOUNT_TYPE_CUSTOMER
    a.is_suspense_receipt_account = true
    a.save!
  end

  def down
    a = Account.find_by_code(ACCOUNT_CODE_SUSPENSE_RECEIPT)
    return unless a
    a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
    a.is_suspense_receipt_account = false
    a.save!
  end
end
