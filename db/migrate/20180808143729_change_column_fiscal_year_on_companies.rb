class ChangeColumnFiscalYearOnCompanies < ActiveRecord::Migration[5.2]
  def up
    change_column :companies, :fiscal_year, :integer, null: true
  end
  def down
    change_column :companies, :fiscal_year, :integer, null: false
  end
end
