class DropTableHouseworks < ActiveRecord::Migration[5.1]
  def up
    drop_table :houseworks
  end
  
  def down
  end
end
