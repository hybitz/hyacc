# -*- encoding : utf-8 -*-
require 'active_record/fixtures'
class CreateInhabitantTaxes < ActiveRecord::Migration
  def self.up
    create_table :inhabitant_taxes do |t|
      t.integer :fy, :null=>false, :limit=>4
      t.integer :user_id, :null=>false, :limit=>11
      t.integer :jun, :limit=>10, :default=>0
      t.integer :jul, :limit=>10, :default=>0
      t.integer :aug, :limit=>10, :default=>0
      t.integer :sep, :limit=>10, :default=>0
      t.integer :oct, :limit=>10, :default=>0
      t.integer :nov, :limit=>10, :default=>0
      t.integer :dec, :limit=>10, :default=>0
      t.integer :jan, :limit=>10, :default=>0
      t.integer :feb, :limit=>10, :default=>0
      t.integer :mar, :limit=>10, :default=>0
      t.integer :apr, :limit=>10, :default=>0
      t.integer :may, :limit=>10, :default=>0
      t.timestamps
    end
      
    # カラム情報を最新にする
    InhabitantTax.reset_column_information

    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20091018215018")
    Fixtures.create_fixtures(dir, "inhabitant_taxes")
  end

  def self.down
    drop_table :inhabitant_taxes
  end
end
