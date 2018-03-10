class AddColumnDeletedOnBusinessOffices < ActiveRecord::Migration[5.1]
  def change
    add_column :business_offices, :deleted, :boolean, null: false, default: false
  end
end
