# -*- encoding : utf-8 -*-
#
# $Id: 20100327015150_insert_data_on_insurances.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InsertDataOnInsurances < ActiveRecord::Migration
  require 'active_record/fixtures'
  def self.up
    # データ削除
    Insurance.delete_all
    # データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20100327015150")
    Fixtures.create_fixtures(dir, "insurances")
  end

  def self.down
  end
end
