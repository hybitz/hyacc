# -*- encoding : utf-8 -*-
#
# $Id: 20101006131336_add_column_is_revenue_reserve_account_on_accounts.rb 2725 2011-12-09 06:14:40Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnIsRevenueReserveAccountOnAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :is_revenue_reserve_account, :boolean, :null=>false, :default=>false
  end

  def self.down
    remove_column :accounts, :is_revenue_reserve_account
  end
end
