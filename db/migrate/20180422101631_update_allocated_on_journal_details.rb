class UpdateAllocatedOnJournalDetails < ActiveRecord::Migration[5.1]
  def up
    JournalDetail.where(is_allocated_assets: true).update_all(['allocated = ?', true])
    JournalDetail.where(is_allocated_cost: true).update_all(['allocated = ?', true])
  end
  
  def down
  end
end
