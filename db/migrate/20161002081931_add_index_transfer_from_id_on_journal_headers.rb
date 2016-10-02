class AddIndexTransferFromIdOnJournalHeaders < ActiveRecord::Migration
  def change
    add_index :journal_headers, :transfer_from_id
  end
end
