class UpdateAutoOnJournalHeaders < ActiveRecord::Migration[5.1]
  include HyaccConstants

  def up
    slip_types = [
      SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_EXPENSE,
      SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST,
      SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS,
      SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE,
      SLIP_TYPE_DEEMED_TAX,
      SLIP_TYPE_DEPRECIATION
    ]
    JournalHeader.where(slip_type: slip_types).update_all(['auto = ?', true])
  end
  
  def down
  end
end
