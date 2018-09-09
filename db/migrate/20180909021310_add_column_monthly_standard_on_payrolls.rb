class AddColumnMonthlyStandardOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :monthly_standard, :integer, null: false, default: 0
  end
end
