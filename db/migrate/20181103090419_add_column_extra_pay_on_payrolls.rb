class AddColumnExtraPayOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :extra_pay, :integer, null: false, default: 0
  end
end
