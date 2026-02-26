class CreateDonationRecipients < ActiveRecord::Migration[7.2]
  def change
    create_table :donation_recipients, id: :integer do |t|
      t.integer :company_id, null: false
      t.string :kind, limit: 3, null: false
      t.string :name, null: false
      t.string :announcement_number
      t.string :purpose
      t.string :address
      t.string :purpose_or_name
      t.string :trust_name
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end
  end
end
