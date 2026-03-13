class AddDonationRecipientIdToJournalDetails < ActiveRecord::Migration[7.2]
  def change
    add_column :journal_details, :donation_recipient_id, :integer
  end
end
