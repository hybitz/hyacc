# -*- encoding : utf-8 -*-
class AddColumnBranchIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, "branch_id", :integer, :default=>0
  end

  def self.down
    remove_column :users, "branch_id"
  end
end
