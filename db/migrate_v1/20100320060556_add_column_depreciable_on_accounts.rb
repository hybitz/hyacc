# -*- encoding : utf-8 -*-
#
# $Id: 20100320060556_add_column_depreciable_on_accounts.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnDepreciableOnAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :accounts, :depreciable, :boolean, :null=>false, :default=>false
    
    # データ移行
    Account.reset_column_information
    Account.find(:all, :conditions=>['path like ?', "%/#{ACCOUNT_CODE_FIXED_ASSET}/%"]).each do |a|
      a.depreciable = true
      a.save!
    end
  end

  def self.down
    remove_column :accounts, :depreciable
  end
end
