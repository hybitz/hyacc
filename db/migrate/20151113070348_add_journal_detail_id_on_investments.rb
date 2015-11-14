class AddJournalDetailIdOnInvestments < ActiveRecord::Migration
  def change
    add_column :investments, :journal_detail_id, :integer
  end
end
