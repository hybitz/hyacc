# -*- encoding : utf-8 -*-
#
# $Id: 20100509095705_add_column_company_only_on_accounts.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnCompanyOnlyOnAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :company_only, :boolean, :null=>false, :default=>false
  end

  def self.down
    remove_column :accounts, :company_only
  end
end
