# -*- encoding : utf-8 -*-
#
# $Id: 20100507081943_add_index_on_housework_details.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddIndexOnHouseworkDetails < ActiveRecord::Migration
  def self.up
    add_index :housework_details, [:housework_id, :account_id, :sub_account_id],
      :name=>"index_housework_details_as_unique_key", :unique=>true
  end

  def self.down
    remove_index :housework_details, :name=>"index_housework_details_as_unique_key"
  end
end
