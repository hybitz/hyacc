class AddColumnAnnualAdjustmentOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :annual_adjustment, :integer, null: false, default: 0
  end
end
