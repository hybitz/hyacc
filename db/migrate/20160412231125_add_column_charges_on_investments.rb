class AddColumnChargesOnInvestments < ActiveRecord::Migration
  def change
    add_column :investments, :charges, :integer, :null => false, :default => 0
  end
end
