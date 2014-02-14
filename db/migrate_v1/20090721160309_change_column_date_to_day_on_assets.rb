# -*- encoding : utf-8 -*-
class ChangeColumnDateToDayOnAssets < ActiveRecord::Migration
  def self.up
    remove_column :assets, "date"
    add_column :assets, "day", :integer, :null=>false, :limit=>2
  end

  def self.down
    remove_column :assets, "day"
    add_column :assets, "date", :integer, :null=>false, :limit=>2
  end
end
