class AddIsTemporaryPaymentAccountToAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :accounts, :is_temporary_payment_account, :boolean, default: false, null: false
  end
end
