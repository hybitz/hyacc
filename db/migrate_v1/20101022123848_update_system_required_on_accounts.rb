# -*- encoding : utf-8 -*-
#
# $Id: 20101022123848_update_system_required_on_accounts.rb 2725 2011-12-09 06:14:40Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateSystemRequiredOnAccounts < ActiveRecord::Migration
  def self.up
    Account.find(:all).each do |a|
      ac = AccountControl.find_by_account_id(a.id)
      if ac.nil?
        ac = AccountControl.new
      end
      ac.account_id = a.id
      ac.system_required = a.system_required
      ac.save!
    end
  end

  def self.down
    AccountControl.find(:all).each do |ac|
      a = Account.find(ac.account_id)
      if a.system_required != ac.system_required
        a.system_required = ac.system_required
        a.save!
      end
    end
    
    AccountControl.delete_all
  end
end
