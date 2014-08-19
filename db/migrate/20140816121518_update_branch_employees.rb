class UpdateBranchEmployees < ActiveRecord::Migration
  def up
    BranchesEmployee.all.each do |a|
      b = BranchEmployee.new
      b.branch_id = a.branch_id
      b.employee_id = a.employee_id
      b.cost_ratio = a.cost_ratio
      b.default_branch = a.default_branch
      b.created_at = a.created_at
      b.updated_at = a.updated_at
      b.save!
    end
  end
  
  def down
  end
end
