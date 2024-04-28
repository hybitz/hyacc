class AddColumnMiscAdjustmentOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :misc_adjustment, :integer, null: false, default: 0
  end
end
