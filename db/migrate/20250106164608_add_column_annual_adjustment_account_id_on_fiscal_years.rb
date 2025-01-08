class AddColumnAnnualAdjustmentAccountIdOnFiscalYears < ActiveRecord::Migration[6.1]
  def change
    add_column :fiscal_years, :annual_adjustment_account_id, :string
  end
end
