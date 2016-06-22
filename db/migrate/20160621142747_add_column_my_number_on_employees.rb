class AddColumnMyNumberOnEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :my_number, :string, :limit => 12
  end
end
