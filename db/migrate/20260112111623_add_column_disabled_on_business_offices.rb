class AddColumnDisabledOnBusinessOffices < ActiveRecord::Migration[5.2]
  def change
    add_column :business_offices, :disabled, :boolean, null: false, default: false
  end
end
