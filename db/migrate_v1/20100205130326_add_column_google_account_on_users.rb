# -*- encoding : utf-8 -*-
class AddColumnGoogleAccountOnUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :google_account, :string
    add_column :users, :crypted_google_password, :string
  end

  def self.down
    remove_column :users, :google_account
    remove_column :users, :crypted_google_password
  end
end
