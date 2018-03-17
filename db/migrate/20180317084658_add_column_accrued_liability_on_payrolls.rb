class AddColumnAccruedLiabilityOnPayrolls < ActiveRecord::Migration[5.1]
  def change
    add_column :payrolls, :accrued_liability, :integer, null: false, default: 0
  end
end
