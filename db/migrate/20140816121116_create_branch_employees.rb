class CreateBranchEmployees < ActiveRecord::Migration
  def change
    create_table :branch_employees do |t|
      t.integer  "branch_id",                      null: false
      t.integer  "employee_id",                    null: false
      t.integer  "cost_ratio",     default: 0,     null: false
      t.boolean  "default_branch", default: false, null: false
      t.timestamps
    end
  end
end
