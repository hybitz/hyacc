# -*- encoding : utf-8 -*-
class RenameColumnYearMonthToYmOnJournalHeaders < ActiveRecord::Migration
  def self.up
    remove_index :journal_headers, :year_month

    add_column :journal_headers, "ym", :integer, :limit => 6, :null => false
    JournalHeader.update_all(["ym=`year_month`"])
    remove_column :journal_headers, "year_month"
    
    add_index :journal_headers, :ym
  end

  def self.down
    remove_index :journal_headers, :ym

    add_column :journal_headers, "year_month", :integer, :limit => 6, :null => false
    JournalHeader.update_all(["`year_month`=ym"])
    remove_column :journal_headers, "ym"

    add_index :journal_headers, :year_month
  end
end
