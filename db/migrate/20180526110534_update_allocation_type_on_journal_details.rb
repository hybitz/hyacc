class UpdateAllocationTypeOnJournalDetails < ActiveRecord::Migration[5.2]
  include HyaccConstants

  def up
    JournalDetail.where(allocated: true).update_all(['allocation_type = ?', ALLOCATION_TYPE_EVEN_BY_SIBLINGS])
  end

  def down
  end
end
