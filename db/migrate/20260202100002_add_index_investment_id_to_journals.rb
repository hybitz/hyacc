class AddIndexInvestmentIdToJournals < ActiveRecord::Migration[7.2]
  def change
    add_index :journals, :investment_id
  end
end
