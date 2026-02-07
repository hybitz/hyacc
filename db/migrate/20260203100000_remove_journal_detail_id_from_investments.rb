class RemoveJournalDetailIdFromInvestments < ActiveRecord::Migration[7.2]
  def change
    remove_column :investments, :journal_detail_id, :integer
  end
end
