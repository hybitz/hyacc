class RenameColumnUpdatedOnToUpdatedAtOnBankAccounts < ActiveRecord::Migration
  def change
    rename_column :bank_accounts, :updated_on, :updated_at
  end
end
