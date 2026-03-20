class BackfillHasAutoTransfersOnJournals < ActiveRecord::Migration[8.1]
  def up
    Journal.find_each do |j|
      has_auto_transfers = j.transfer_journals.exists? || j.journal_details.any? { |jd| jd.transfer_journals.exists? }
      j.update_column(:has_auto_transfers, has_auto_transfers)
    end
  end

  def down
    Journal.where(has_auto_transfers: true).update_all(has_auto_transfers: nil)
  end
end
