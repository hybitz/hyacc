# -*- encoding : utf-8 -*-
class UpdateColumnDeletedToSubAccounts < ActiveRecord::Migration

  def self.up
    remove_column :sub_accounts, "deleted"
    add_column :sub_accounts, "deleted", :boolean, :null=>false, :default => false
  end

  def self.down
    remove_column :sub_accounts, "deleted"
    add_column :sub_accounts, "deleted", :integer, :null=>false, :default => 0
  end
end
