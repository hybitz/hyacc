class RemoveColumnIsRevenueReserveAccountOnAccounts < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :is_revenue_reserve_account, :boolean, null: false, default: false
  end
end
