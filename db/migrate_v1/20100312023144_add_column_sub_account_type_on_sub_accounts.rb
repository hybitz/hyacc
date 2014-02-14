# -*- encoding : utf-8 -*-
#
# $Id: 20100312023144_add_column_sub_account_type_on_sub_accounts.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnSubAccountTypeOnSubAccounts < ActiveRecord::Migration
  def self.up
    add_column :sub_accounts, :sub_account_type, :integer, :limit=>2, :null=>false, :default=>1
    add_column :sub_accounts, :social_expense_number_of_people_required, :boolean, :null=>false, :default=>false
  end

  def self.down
    remove_column :sub_accounts, :sub_account_type
    remove_column :sub_accounts, :social_expense_number_of_people_required
  end
end
