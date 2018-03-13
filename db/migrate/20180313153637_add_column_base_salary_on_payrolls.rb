class AddColumnBaseSalaryOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :base_salary, :integer, null: false, default: 0
  end
end
