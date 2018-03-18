class RemoveColumnCarryStatusOnFiscalYears < ActiveRecord::Migration[5.1]
  def change
    remove_column :fiscal_years, :carry_status, :boolean, null: false, default: false
  end
end
