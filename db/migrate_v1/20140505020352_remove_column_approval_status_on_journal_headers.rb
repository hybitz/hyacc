class RemoveColumnApprovalStatusOnJournalHeaders < ActiveRecord::Migration
  def up
    remove_column :journal_headers, :approval_status
  end

  def down
    add_column :journal_headers, :approval_status, :boolean, :null => false, :default => false
  end
end
