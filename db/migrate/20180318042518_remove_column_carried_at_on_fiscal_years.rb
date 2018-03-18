class RemoveColumnCarriedAtOnFiscalYears < ActiveRecord::Migration[5.1]
  def change
    remove_column :fiscal_years, :carried_at, :datetime
  end
end
