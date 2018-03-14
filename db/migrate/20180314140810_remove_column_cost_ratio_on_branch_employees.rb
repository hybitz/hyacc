class RemoveColumnCostRatioOnBranchEmployees < ActiveRecord::Migration[5.1]
  def change
    remove_column :branch_employees, :cost_ratio, :integer, null: false, default: 0
  end
end
