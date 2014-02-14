# -*- encoding : utf-8 -*-
class CreateTableDepreciationRates < ActiveRecord::Migration
  require 'active_record/fixtures'
  
  def self.up
    create_table :depreciation_rates do |t|
      t.integer :durable_years, :limit=>2, :null=>false
      t.decimal :fixed_amount_rate, :null=>false, :precision=>4, :scale=>3
      t.decimal :rate, :null=>false, :precision=>4, :scale=>3
      t.decimal :revised_rate, :null=>false, :precision=>4, :scale=>3
      t.decimal :guaranteed_rate, :null=>false, :precision=>6, :scale=>5
      t.boolean :deleted, :null => false, :default=>false
      t.timestamps
    end
    
    # カラム情報を最新にする
    DepreciationRate.reset_column_information

    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20090714111411")
    Fixtures.create_fixtures(dir, "depreciation_rates")
  end

  def self.down
    drop_table :depreciation_rates
  end
end
