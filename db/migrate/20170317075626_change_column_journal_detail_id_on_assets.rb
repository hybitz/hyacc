class ChangeColumnJournalDetailIdOnAssets < ActiveRecord::Migration[5.0]
  def up
    change_column :assets, :journal_detail_id, :integer, :null => false
  end

  def down
    change_column :assets, :journal_detail_id, :integer, :null => true
  end
end
