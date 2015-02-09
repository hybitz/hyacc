class RenameColumnCreatedOnToCreatedAtOnBankAccounts < ActiveRecord::Migration
  def change
    rename_column :bank_accounts, :created_on, :created_at
  end
end
