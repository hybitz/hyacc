# -*- encoding : utf-8 -*-
class AddCryptPasswordAndSaltToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :crypted_password, :string, :null=>false
    add_column :users, :salt, :string, :null=>false
    
    # カラム情報を最新にする
    User.reset_column_information
    User.find(:all).each{|u|
      result = ActiveRecord::Base.connection.execute('select password from users where id = ' + u.id.to_s)
      u.password = result.fetch_row.first
      result.free
      u.save
    }
    remove_column :users, :password
  end

  def self.down
    remove_column :users, :salt
    remove_column :users, :crypted_password
    add_column :users, :password, :string, :null=>false
  end
end
