# -*- encoding : utf-8 -*-
#
# $Id: 20110114015537_create_table_business_offices.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateTableBusinessOffices < ActiveRecord::Migration
  def self.up
    create_table :business_offices, :force => true do |t|
      t.integer :company_id, :null=>false
      t.string  :name, :null=>false
      t.integer :prefecture_id, :null=>false
      t.string :prefecture_name, :null=>false, :limit=>16
      t.string :address1
      t.string :address2
      t.timestamps
      t.integer :lock_version, :default=>0, :null=>false
    end
  end

  def self.down
    drop_table :business_offices
  end
end
