class ChangeColumnZipCodeOnEmployees < ActiveRecord::Migration
  def up
    change_column :employees, :zip_code, :string, limit: 8
  end
  def down
    change_column :employees, :zip_code, :string, limit: 255
  end
end
