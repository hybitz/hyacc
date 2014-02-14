# -*- encoding : utf-8 -*-
class ChangeColumnDepreciationMethodOnAssets < ActiveRecord::Migration
  def self.up
    change_column :assets, :depreciation_method, :integer, :limit=>1, :null=>true
  end

  def self.down
    change_column :assets, :depreciation_method, :integer, :limit=>2, :null=>false
  end
end
