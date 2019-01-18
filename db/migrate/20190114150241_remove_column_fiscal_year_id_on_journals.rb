class RemoveColumnFiscalYearIdOnJournals < ActiveRecord::Migration[5.2]
  def change
    remove_column :journals, :fiscal_year_id, :integer
  end
end
