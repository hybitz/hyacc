class AddColumnHouseLoanOnExemptions < ActiveRecord::Migration[5.0]
  def change
    add_column :exemptions, :house_loan, :integer, :null => false, :default => 0
  end
end
