class RenameColumnUpdatedOnToUpdatedAtOnSubAccounts < ActiveRecord::Migration
  def change
    rename_column :sub_accounts, :updated_on, :updated_at
  end
end
