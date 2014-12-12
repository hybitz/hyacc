class AddColumnApprovalStatusOnJournalHeaders < ActiveRecord::Migration
  def self.up
    add_column :journal_headers, :approval_status, :integer, :limit=>1, :default=>0, :null=>false
  end

  def self.down
    remove_column :journal_headers, :approval_status
  end
end
