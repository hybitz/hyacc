class RenameColumnJournalHeaderIdToJournalIdOnJournalDetails < ActiveRecord::Migration[5.2]
  def change
    rename_column :journal_details, :journal_header_id, :journal_id
  end
end
