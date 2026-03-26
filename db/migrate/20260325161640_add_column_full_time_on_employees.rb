class AddColumnFullTimeOnEmployees < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :full_time, :boolean
  end
end

