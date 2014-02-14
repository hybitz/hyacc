# -*- encoding : utf-8 -*-
#
# $Id: 20100507070949_add_column_sub_account_id_on_housework_details.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnSubAccountIdOnHouseworkDetails < ActiveRecord::Migration
  def self.up
    add_column :housework_details, :sub_account_id, :integer
  end

  def self.down
    remove_column :housework_details, :sub_account_id
  end
end
