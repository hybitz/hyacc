# -*- encoding : utf-8 -*-
require 'active_record/fixtures'

class CreateTableUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "code", :string, :null => false
      t.column "login_id", :string, :null => false
      t.column "password", :string, :null => false
      t.column "first_name", :string, :null => false
      t.column "last_name", :string, :null => false
      t.column "deleted", :boolean, :null => false, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    add_index :users, :login_id, :unique => true
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/001")
    Fixtures.create_fixtures(dir, "users")
    now = Time.now
    User.update_all(["created_on=?, updated_on=?", now, now ])
  end

  def self.down
    User.delete_all
    remove_index :users, :login_id
    drop_table :users
  end
end
