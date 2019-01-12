class UpdateIsSuspenseReceiptAccountOnAccounts < ActiveRecord::Migration[5.2]
  include HyaccConstants

  def up
    [ACCOUNT_CODE_DEPOSITS_RECEIVED].each do |code|
      a = Account.find_by_code(code)
      a.is_suspense_receipt_account = true
      a.save!
    end
  end
  
  def down
  end
end
