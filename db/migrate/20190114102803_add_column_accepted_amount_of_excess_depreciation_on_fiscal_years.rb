class AddColumnAcceptedAmountOfExcessDepreciationOnFiscalYears < ActiveRecord::Migration[5.2]
  def change
    add_column :fiscal_years, :accepted_amount_of_excess_depreciation, :integer, null: false, default: 0
  end
end
