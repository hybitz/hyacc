class RenameColumnUpdatedOnToUpdatedAtOnFiscalYears < ActiveRecord::Migration
  def change
    rename_column :fiscal_years, :updated_on, :updated_at
  end
end
