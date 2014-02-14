# -*- encoding : utf-8 -*-
class AddColumnBranchFinderKeyToJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, "branch_finder_key", :string
    
    # 既存のレコードのbranch_finder_keyを設定
    JournalHeader.find(:all).each do | jh |
      jh.save!
    end
  end

  def self.down
    remove_column :journal_headers, "branch_finder_key"
  end
end
