class CreateJournalDetailDonationRecipients < ActiveRecord::Migration[7.2]
  def change
    create_table :journal_detail_donation_recipients, id: :integer do |t|
      t.integer :journal_detail_id, null: false
      t.integer :donation_recipient_id, null: false
      t.timestamps
      t.index :journal_detail_id, unique: true
    end
  end
end
