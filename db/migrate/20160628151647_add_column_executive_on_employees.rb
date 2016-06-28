class AddColumnExecutiveOnEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :executive, :boolean, :null => false, :default => false
  end
end
