class AddFixedTaxDeductionAmountToExemptions < ActiveRecord::Migration[5.2]
  def change
    add_column :exemptions, :fixed_tax_deduction_amount, :integer
  end
end
