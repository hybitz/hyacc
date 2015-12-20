class DropTableAccountControls < ActiveRecord::Migration
  def up
    drop_table :account_controls
  end
  
  def down
  end
end
