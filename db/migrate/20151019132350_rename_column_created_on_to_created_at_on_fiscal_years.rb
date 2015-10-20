class RenameColumnCreatedOnToCreatedAtOnFiscalYears < ActiveRecord::Migration
  def change
    rename_column :fiscal_years, :created_on, :created_at
  end
end
