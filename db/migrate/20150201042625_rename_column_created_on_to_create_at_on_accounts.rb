class RenameColumnCreatedOnToCreateAtOnAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :created_on, :created_at
  end
end
