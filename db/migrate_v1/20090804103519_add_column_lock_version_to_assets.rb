# -*- encoding : utf-8 -*-
class AddColumnLockVersionToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :lock_version, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :assets, :lock_version
  end
end
