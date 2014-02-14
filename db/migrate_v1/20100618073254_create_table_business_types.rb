# -*- encoding : utf-8 -*-
#
# $Id: 20100618073254_create_table_business_types.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableBusinessTypes < ActiveRecord::Migration
  def self.up
    create_table :business_types, :force => true do |t|
      t.string :name, :null=>false, :limit=>32
      t.string :description
      t.decimal :deemed_tax_ratio, :null=>false, :precision=>3, :scale =>2
      t.boolean  :deleted, :default=>false, :null=>false
      t.timestamps
    end

    add_index :business_types, [:name], :unique=>true, :name=>'index_bisiness_types_on_name'
  end

  def self.down
    drop_table :business_types
  end
end
