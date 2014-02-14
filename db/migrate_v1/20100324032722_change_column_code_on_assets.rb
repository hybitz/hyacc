# -*- encoding : utf-8 -*-
#
# $Id: 20100324032722_change_column_code_on_assets.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Util
  include AssetUtil
end

class ChangeColumnCodeOnAssets < ActiveRecord::Migration
  def self.up
    create_table :sequences, :id=>false, :force=>true do |t|
      t.string :name, :null=>false
      t.string :section
      t.integer :value, :null=>false, :default=>0
      t.timestamps
    end
    
    add_index :sequences, [:name, :section], :unique=>true,
        :name=>'index_sequences_on_name_and_section'
    
    FiscalYear.find(:all).each do |fy|
      Sequence.create_sequence(Asset, fy.fiscal_year)
    end

    change_column :assets, :code, :string, :null=>false, :limit=>8
    
    # データ移行
    util = Util.new
    Asset.reset_column_information
    Asset.find(:all).each do |a|
      a.code = util.create_asset_code(a.start_fiscal_year)
      a.save!
    end
  end

  def self.down
    drop_table :sequences
  end
end
