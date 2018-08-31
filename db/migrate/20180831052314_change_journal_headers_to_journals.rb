class ChangeJournalHeadersToJournals < ActiveRecord::Migration[5.2]
  def change
    rename_table :journal_headers, :journals
  end
end
