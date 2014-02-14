# -*- encoding : utf-8 -*-
class ChangeColumnSubAccountIdOnAssets < ActiveRecord::Migration
  def self.up
    change_column :assets, :sub_account_id, :integer, :null=>true
  end

  def self.down
    change_column :assets, :sub_account_id, :integer, :null=>false
  end
end
