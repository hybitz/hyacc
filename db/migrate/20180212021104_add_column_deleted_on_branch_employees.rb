class AddColumnDeletedOnBranchEmployees < ActiveRecord::Migration[5.1]
  def change
    add_column :branch_employees, :deleted, :boolean, null: false, default: false
  end
end
