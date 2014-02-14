# -*- encoding : utf-8 -*-
class AddColumnSlipTypeToJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, "slip_type", :integer, :limit => 2
    
    # 既存のレコードは、振替伝票で起票したこととして更新
    JournalHeader.update_all("slip_type=1")
  end

  def self.down
    remove_column :journal_headers, "slip_type"
  end
end
