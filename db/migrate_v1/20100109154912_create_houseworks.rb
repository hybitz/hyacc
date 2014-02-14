# -*- encoding : utf-8 -*-
class CreateHouseworks < ActiveRecord::Migration
  def self.up
    create_table :houseworks do |t|
      t.integer :fiscal_year, :null=>false, :limit=>4
      t.timestamps
    end
    
    add_index :houseworks, :fiscal_year, :unique=>true, :name=>:index_houseworks_on_fiscal_year

    create_table :housework_details do |t|
      t.integer :housework_id, :null=>false
      t.integer :account_id, :null=>false
      t.decimal :business_ratio, :precision=>5, :scale=>2, :null=>false
      t.timestamps
    end
    
    add_index :housework_details, [:housework_id, :account_id], :unique=>true,
      :name=>:index_housework_details_on_housework_id_and_account_id

    add_column :journal_headers, :housework_id, :integer
    add_column :journal_details, :housework_detail_id, :integer
  end

  def self.down
    remove_column :journal_details, :housework_detail_id
    remove_column :journal_headers, :housework_id
    drop_table :housework_details
    drop_table :houseworks
  end
end
