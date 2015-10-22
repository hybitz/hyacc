class AddColumnCustomerIdOnInvestments < ActiveRecord::Migration
  def up
    add_column :investments, :customer_id, :integer
    remove_column :investments, :name
  end

  def down
    add_column :investments, :name, :string, :null => false
    remove_column :investments, :customer_id
  end

end
