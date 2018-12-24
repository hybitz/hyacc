class RemoveColumnMortgageDeductionOnExemptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :exemptions, :mortgage_deduction, :integer
  end
end
