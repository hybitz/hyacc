class AddColumnTemporarySalaryOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :temporary_salary, :integer, null: false, default: 0
  end
end
