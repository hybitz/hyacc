# -*- encoding : utf-8 -*-
class CreateTableDepreciations < ActiveRecord::Migration
  def self.up
    add_column :assets, :start_fiscal_year, :integer, :limit=>4, :null=>true
    add_column :assets, :end_fiscal_year, :integer, :limit=>4, :null=>true
    add_column :journal_headers, :depreciation_id, :integer, :null=>true
    
    create_table :depreciations do |t|
      t.integer :asset_id, :null=>false
      t.integer :fiscal_year, :null=>false
      t.integer :amount_at_start, :null=>false
      t.integer :amount_at_end, :null=>false
      t.boolean :depreciated, :null=>false, :default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :depreciations
    remove_column :assets, :start_fiscal_year
    remove_column :assets, :end_fiscal_year
    remove_column :journal_headers, :depreciation_id
  end
end
