class ChangeColumnSlipTypeOnJournalHeaders < ActiveRecord::Migration[5.0]
  def up
    change_column :journal_headers, :slip_type, :integer, :null => false
  end
  
  def down
    change_column :journal_headers, :slip_type, :integer, :null => true
  end
end
