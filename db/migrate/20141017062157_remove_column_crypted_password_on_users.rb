class RemoveColumnCryptedPasswordOnUsers < ActiveRecord::Migration
  def up
    User.connection.update('update users set encrypted_password = crypted_password')
    remove_column :users, :crypted_password
  end
  
  def down
    add_column :users, :crypted_password, :string, :null => false
    User.connection.update('update users set crypted_password = encrypted_password')
  end
end
