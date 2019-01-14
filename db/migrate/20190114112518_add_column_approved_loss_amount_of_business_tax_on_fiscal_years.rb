class AddColumnApprovedLossAmountOfBusinessTaxOnFiscalYears < ActiveRecord::Migration[5.2]
  def change
    add_column :fiscal_years, :approved_loss_amount_of_business_tax, :integer, null: false, default: 0
  end
end
