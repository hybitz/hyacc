class AddColumnDisabledOnCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :disabled, :boolean, :null => false, :default => false
  end
end
