class AddColumnSubAccountEditableOnAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :sub_account_editable, :boolean, null: false, default: true
  end
end
