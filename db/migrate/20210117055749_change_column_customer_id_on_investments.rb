class ChangeColumnCustomerIdOnInvestments < ActiveRecord::Migration[5.2]
  def up
    change_column :investments, :customer_id, :integer, null: false
  end
  def down
    change_column :investments, :customer_id, :integer, null: true
  end
end
