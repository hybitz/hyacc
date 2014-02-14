# -*- encoding : utf-8 -*-
class AddParentIdAndPathToBranches < ActiveRecord::Migration
  def self.up
    add_column :branches, :parent_id, :integer, :null=>false, :limit=>11, :default=>0
    add_column :branches, :path, :string, :null=>false, :default=>"/"
    add_column :branches, :cost_ratio, :integer, :null=>false, :limit=>11, :default=>100
    add_column :branches, :company_id, :integer, :null=>false, :limit=>11
    
    # カラム情報を最新にする
    Branch.reset_column_information
    Branch.find(:all).each do |b|
      if b.id == 1
        b.parent_id = 0
        b.path = "/1"
        b.cost_ratio = 100
        b.company_id = 1
      elsif b.id == 2
        b.parent_id = 1
        b.path = "/1/2"
        b.cost_ratio = 50
        b.company_id = 1
      elsif b.id == 3
        b.parent_id = 1
        b.path = "/1/3"
        b.cost_ratio = 50
        b.company_id = 1
      end
      b.save!
    end
  end

  def self.down
    remove_column :branches, :cost_ratio
    remove_column :branches, :path
    remove_column :branches, :parent_id
    remove_column :branches, :company_id
  end
end
