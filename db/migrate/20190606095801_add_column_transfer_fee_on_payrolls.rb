class AddColumnTransferFeeOnPayrolls < ActiveRecord::Migration[5.2]
  def change
    add_column :payrolls, :transfer_fee, :integer, null: false, default: 0
  end
end
