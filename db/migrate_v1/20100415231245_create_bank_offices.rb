# -*- encoding : utf-8 -*-
#
# $Id: 20100415231245_create_bank_offices.rb 2168 2010-04-27 12:47:00Z hiro $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateBankOffices < ActiveRecord::Migration
  require 'active_record/fixtures'
  def self.up
    create_table :bank_offices do |t|
      t.integer :bank_id, :null=>false
      t.string :name, :null=>false
      t.string :code, :null=>false, :limit=>3
      t.boolean :deleted

      t.timestamps
    end
    
    # カラム情報を最新にする
    BankOffice.reset_column_information
    # データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20100415231245")
    Fixtures.create_fixtures(dir, "bank_offices")
  end

  def self.down
    drop_table :bank_offices
  end
end
