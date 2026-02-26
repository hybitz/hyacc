class JournalDetailDonationRecipient < ApplicationRecord
  belongs_to :journal_detail
  belongs_to :donation_recipient, optional: true  # 寄付先は未選択でも登録可能

  validates :journal_detail_id, uniqueness: true
end
