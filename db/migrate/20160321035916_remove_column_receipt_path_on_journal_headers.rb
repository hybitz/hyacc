class RemoveColumnReceiptPathOnJournalHeaders < ActiveRecord::Migration
  def up
    remove_column :journal_headers, :receipt_path
  end
  def down
    add_column :journal_headers, :receipt_path, :string
  end
end
