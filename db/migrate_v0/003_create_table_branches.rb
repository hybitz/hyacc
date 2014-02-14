# -*- encoding : utf-8 -*-
class CreateTableBranches < ActiveRecord::Migration
  def self.up
    create_table :branches do |t|
      t.column "code", :string, :null => false
      t.column "name", :string, :null => false
      t.column "deleted", :boolean, :null => false, :default => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/003")
    Fixtures.create_fixtures(dir, "branches")
    now = Time.now
    Branch.update_all(["created_on=?, updated_on=?", now, now ])
  end

  def self.down
    drop_table :branches
  end
end
