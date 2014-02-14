# -*- encoding : utf-8 -*-
class CreateTableAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :code, :null=>false
      t.string :name, :null=>false
      t.integer :account_id, :null=>false
      t.integer :branch_id, :null=>false
      t.integer :sub_account_id, :null=>false
      t.integer :durable_years, :limit=>2
      t.integer :ym, :null=>false, :limit=>6
      t.integer :date, :null=>false, :limit=>2
      t.integer :amount, :null=>false
      t.integer :depreciation_method, :null=>false, :limit=>2
      t.integer :depreciation_limit
      t.string :remarks
      t.decimal :business_use_ratio, :precision=>5, :scale=>2
      t.boolean :deleted, :null => false, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
