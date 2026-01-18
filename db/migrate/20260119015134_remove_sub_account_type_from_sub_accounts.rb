class RemoveSubAccountTypeFromSubAccounts < ActiveRecord::Migration[7.2]
  def change
    remove_column :sub_accounts, :sub_account_type, :integer, limit: 2, default: 1, null: false
  end
end
