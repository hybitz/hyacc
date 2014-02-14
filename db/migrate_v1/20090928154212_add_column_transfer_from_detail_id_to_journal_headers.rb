# -*- encoding : utf-8 -*-
class AddColumnTransferFromDetailIdToJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, :transfer_from_detail_id, :integer
  end

  def self.down
    remove_column :journal_headers, :transfer_from_detail_id
  end
end
