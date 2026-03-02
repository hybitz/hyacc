class JournalDetailDonationRecipient < ApplicationRecord
  belongs_to :journal_detail
  belongs_to :donation_recipient

  validates :journal_detail_id, uniqueness: true
end
