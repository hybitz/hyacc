# -*- encoding : utf-8 -*-
require 'active_record/fixtures'
class AddYmAndAmountToInhabitantTaxes < ActiveRecord::Migration
  def self.up
    add_column :inhabitant_taxes, :ym, :integer, :null=>false
    add_column :inhabitant_taxes, :amount, :integer
    
    remove_column :inhabitant_taxes,  :fy
    remove_column :inhabitant_taxes,  :jun
    remove_column :inhabitant_taxes,  :jul
    remove_column :inhabitant_taxes,  :aug
    remove_column :inhabitant_taxes,  :sep
    remove_column :inhabitant_taxes,  :oct
    remove_column :inhabitant_taxes,  :nov
    remove_column :inhabitant_taxes,  :dec
    remove_column :inhabitant_taxes,  :jan
    remove_column :inhabitant_taxes,  :feb
    remove_column :inhabitant_taxes,  :mar
    remove_column :inhabitant_taxes,  :apr
    remove_column :inhabitant_taxes,  :may
    # カラム情報を最新にする
    InhabitantTax.reset_column_information
    InhabitantTax.delete_all
    
    # 初期データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20110218013116")
    Fixtures.create_fixtures(dir, "inhabitant_taxes")
    
  end

  def self.down
    add_column :inhabitant_taxes, :fy, :integer, :null=>false, :limit=>4
    add_column :inhabitant_taxes, :jun, :integer, :default=>0
    add_column :inhabitant_taxes, :jul, :integer, :default=>0
    add_column :inhabitant_taxes, :aug, :integer, :default=>0
    add_column :inhabitant_taxes, :sep, :integer, :default=>0
    add_column :inhabitant_taxes, :oct, :integer, :default=>0
    add_column :inhabitant_taxes, :nov, :integer, :default=>0
    add_column :inhabitant_taxes, :dec, :integer, :default=>0
    add_column :inhabitant_taxes, :jan, :integer, :default=>0
    add_column :inhabitant_taxes, :feb, :integer, :default=>0
    add_column :inhabitant_taxes, :mar, :integer, :default=>0
    add_column :inhabitant_taxes, :apr, :integer, :default=>0
    add_column :inhabitant_taxes, :may, :integer, :default=>0
    
    remove_column :inhabitant_taxes, :ym
    remove_column :inhabitant_taxes, :amount
    
  end
end
