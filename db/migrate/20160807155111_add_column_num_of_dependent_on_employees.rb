class AddColumnNumOfDependentOnEmployees < ActiveRecord::Migration
  def change
    add_column :employees, :num_of_dependent, :integer, :null => false, :default => 0
  end
end
