# -*- encoding : utf-8 -*-
class AddColumnLockVersionToJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, "lock_version", :integer, :null=>false, :default=>0
  end

  def self.down
    remove_column :journal_headers, "lock_version"
  end
end
