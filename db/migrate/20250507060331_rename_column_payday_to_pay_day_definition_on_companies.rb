class RenameColumnPaydayToPayDayDefinitionOnCompanies < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :payday, :pay_day_definition
  end
end
