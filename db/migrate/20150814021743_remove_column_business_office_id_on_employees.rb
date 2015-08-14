class RemoveColumnBusinessOfficeIdOnEmployees < ActiveRecord::Migration
  def up
    remove_column :employees, :business_office_id, :integer
  end

  def down
    add_column :employees, :business_office_id, :integer
  end
end
