class AddColumnSystemRequiredOnAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :system_required, :boolean, null: false, default: false
  end
end
