# -*- encoding : utf-8 -*-
#
# $Id: 20100426143451_insert_data_on_withheld_taxes201004.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InsertDataOnWithheldTaxes201004 < ActiveRecord::Migration
  require 'active_record/fixtures'
  def self.up
    # データ削除
    WithheldTax.delete_all
    # データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20100426143451")
    Fixtures.create_fixtures(dir, "withheld_taxes")
  end

  def self.down
  end
end
