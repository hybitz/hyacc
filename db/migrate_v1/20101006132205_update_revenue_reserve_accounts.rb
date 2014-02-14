# -*- encoding : utf-8 -*-
#
# $Id: 20101006132205_update_revenue_reserve_accounts.rb 2725 2011-12-09 06:14:40Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateRevenueReserveAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    Account.find(:all, :conditions=>["account_type=? and name='利益準備金'", ACCOUNT_TYPE_CAPITAL]).each do |a|
      a.is_revenue_reserve_account = true
      a.save!
    end
  end

  def self.down
  end
end
