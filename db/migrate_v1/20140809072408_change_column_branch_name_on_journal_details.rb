class ChangeColumnBranchNameOnJournalDetails < ActiveRecord::Migration
  def up
    change_column :journal_details, :branch_name, :string, :null => false
  end

  def down
    change_column :journal_details, :branch_name, :string, :null => true
  end
end
