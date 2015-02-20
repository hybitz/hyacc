class RemoveColumnEmployeeIdOnUsers < ActiveRecord::Migration
  def up
    remove_column :users, :employee_id
  end
  
  def down
    add_column :users, :employee_id, :integer
  end
end
