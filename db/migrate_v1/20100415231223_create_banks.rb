# -*- encoding : utf-8 -*-
#
# $Id: 20100415231223_create_banks.rb 2168 2010-04-27 12:47:00Z hiro $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CreateBanks < ActiveRecord::Migration
  require 'active_record/fixtures'
  def self.up
    create_table :banks do |t|
      t.string :name, :null=>false
      t.string :code, :null=>false, :limit=>4
      t.boolean :deleted

      t.timestamps
    end
    
    # カラム情報を最新にする
    Bank.reset_column_information
    # データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20100415231223")
    Fixtures.create_fixtures(dir, "banks")
  end

  def self.down
    drop_table :banks
  end
end
