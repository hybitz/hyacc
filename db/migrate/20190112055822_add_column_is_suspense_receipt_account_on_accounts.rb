class AddColumnIsSuspenseReceiptAccountOnAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :is_suspense_receipt_account, :boolean, null: false, default: false
  end
end
