class AddColumnIsInvestmentOnCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :is_investment, :boolean, :null=>false, :default => false
  end
end
