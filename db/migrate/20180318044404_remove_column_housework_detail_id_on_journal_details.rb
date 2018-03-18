class RemoveColumnHouseworkDetailIdOnJournalDetails < ActiveRecord::Migration[5.1]
  def up
    remove_column :journal_details, :housework_detail_id
  end
  
  def down
  end
end
