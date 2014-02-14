# -*- encoding : utf-8 -*-
#
# $Id: 20101127153020_add_column_is_tax_account_on_accounts.rb 2727 2011-12-09 06:17:17Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnIsTaxAccountOnAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :is_tax_account, :integer, :limit=>1, :null=>false, :default=>false
  end

  def self.down
    remove_column :accounts, :is_tax_account
  end
end
