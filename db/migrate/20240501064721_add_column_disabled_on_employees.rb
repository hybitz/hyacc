class AddColumnDisabledOnEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :disabled, :boolean, null: false, default: false
  end
end
