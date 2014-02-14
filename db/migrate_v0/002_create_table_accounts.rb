# -*- encoding : utf-8 -*-
class CreateTableAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.column "code", :string, :null => false
      t.column "name", :string, :null => false
      t.column "dc_type", :integer, :limit => 1, :null => false
      t.column "account_type", :integer, :limit => 1, :null => false
      t.column "deleted", :boolean, :null => false, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    add_index :accounts, :code, :unique => true
    add_index :accounts, :name, :unique => true
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/002")
    Fixtures.create_fixtures(dir, "accounts")
    now = Time.now
    Account.update_all(["created_on=?, updated_on=?", now, now ])
  end

  def self.down
    remove_index :accounts, :name
    remove_index :accounts, :code
    drop_table :accounts
  end
end
