# -*- encoding : utf-8 -*-
#
# $Id: 20100925122750_insert_data_on_insurances201009.rb 2724 2011-12-09 06:13:45Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InsertDataOnInsurances201009 < ActiveRecord::Migration
  require 'active_record/fixtures'
  def self.up
    # データ削除
    Insurance.delete_all
    # データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20100925122750")
    Fixtures.create_fixtures(dir, "insurances")
  end

  def self.down
  end
end
