# -*- encoding : utf-8 -*-
class RemoveColumnBranchIdFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, "branch_id"
  end

  def self.down
    add_column :users, "branch_id", :integer, :default=>0
  end
end
