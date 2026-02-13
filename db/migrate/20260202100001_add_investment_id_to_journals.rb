class AddInvestmentIdToJournals < ActiveRecord::Migration[7.2]
  def change
    add_column :journals, :investment_id, :integer
  end
end
