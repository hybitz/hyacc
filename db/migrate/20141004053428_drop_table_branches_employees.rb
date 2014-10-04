class DropTableBranchesEmployees < ActiveRecord::Migration
  def up
    drop_table :branches_employees
  end
  
  def down
  end
end
