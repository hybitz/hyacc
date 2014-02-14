# -*- encoding : utf-8 -*-
class CreateTableBranchesUsers < ActiveRecord::Migration
  def self.up
    create_table :branches_users, :id => false, :force => true do |t|
      t.column "branch_id", :integer, :default => 0
      t.column "user_id", :integer, :default => 0
      t.column "cost_ratio", :integer, :limit => 100, :default => 0
      t.column "default_branch", :boolean, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/009")
    Fixtures.create_fixtures(dir, "branches_users")
    now = Time.now
    BranchesUser.update_all(["created_on=?, updated_on=?", now, now ])
  end

  def self.down
    drop_table :branches_users
  end
end
