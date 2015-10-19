class RenameColumnCreatedOnToCreatedAtOnSubAccounts < ActiveRecord::Migration
  def change
    rename_column :sub_accounts, :created_on, :created_at
  end
end
