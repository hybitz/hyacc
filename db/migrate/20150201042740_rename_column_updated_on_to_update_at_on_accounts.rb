class RenameColumnUpdatedOnToUpdateAtOnAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :updated_on, :updated_at
  end
end
