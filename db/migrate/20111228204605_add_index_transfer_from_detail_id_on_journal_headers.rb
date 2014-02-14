class AddIndexTransferFromDetailIdOnJournalHeaders < ActiveRecord::Migration
  def self.up
    add_index :journal_headers, :transfer_from_detail_id, :name=>"index_journal_headers_transfer_from_detail_id", :unique=>false
  end

  def self.down
    remove_index :journal_headers, :name=>"index_journal_headers_transfer_from_detail_id"
  end
end
