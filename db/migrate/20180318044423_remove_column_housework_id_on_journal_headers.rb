class RemoveColumnHouseworkIdOnJournalHeaders < ActiveRecord::Migration[5.1]
  def up
    remove_column :journal_headers, :housework_id
  end
  
  def down
  end
end
