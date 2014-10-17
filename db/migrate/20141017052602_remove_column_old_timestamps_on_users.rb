class RemoveColumnOldTimestampsOnUsers < ActiveRecord::Migration
  def up
    User.connection.update('update users set created_at = created_on, updated_at = updated_on')
    remove_column :users, :created_on
    remove_column :users, :updated_on
  end
  
  def down
    add_column :users, :created_on, :datetime
    add_column :users, :updated_on, :datetime
    User.connection.update('update users set created_on = created_at, updated_on = updated_at')
  end
end
