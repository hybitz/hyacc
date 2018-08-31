class RenameColumnJournalHeaderIdToJournalIdOnReceipts < ActiveRecord::Migration[5.2]
  def change
    rename_column :receipts, :journal_header_id, :journal_id
  end
end
