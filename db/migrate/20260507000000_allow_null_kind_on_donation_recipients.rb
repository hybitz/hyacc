class AllowNullKindOnDonationRecipients < ActiveRecord::Migration[8.1]
  def change
    change_column_null :donation_recipients, :kind, true
  end
end
