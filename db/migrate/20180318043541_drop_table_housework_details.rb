class DropTableHouseworkDetails < ActiveRecord::Migration[5.1]
  def up
    drop_table :housework_details
  end
  
  def down
  end
end
