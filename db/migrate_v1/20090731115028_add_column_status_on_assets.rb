# -*- encoding : utf-8 -*-
class AddColumnStatusOnAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :status, :integer, :limit=>1, :null=>false
    
    # ついでにインデックスも忘れてたので追加
    add_index :assets, :code, :unique => true
  end

  def self.down
    remove_index :assets, :code
    remove_column :assets, :status
  end
end
