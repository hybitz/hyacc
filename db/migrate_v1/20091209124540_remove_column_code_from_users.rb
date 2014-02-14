# -*- encoding : utf-8 -*-
class RemoveColumnCodeFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :code
  end

  def self.down
    add_column :users, :code, :string, :null=>false
  end
end
