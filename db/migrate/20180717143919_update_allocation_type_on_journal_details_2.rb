class UpdateAllocationTypeOnJournalDetails2 < ActiveRecord::Migration[5.2]
  def up
    Branch.where(parent_id: nil).find_each do |head_office|
      JournalDetail.where(allocation_type: 1, branch_id: head_office.id).update_all(['allocation_type = ?', 3])
    end
  end
  
  def down
    JournalDetail.where(allocation_type: [1, 3]).update_all(['allocation_type = ?', 1])
  end
end
