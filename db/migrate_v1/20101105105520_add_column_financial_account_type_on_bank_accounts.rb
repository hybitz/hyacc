# -*- encoding : utf-8 -*-
#
# $Id: 20101105105520_add_column_financial_account_type_on_bank_accounts.rb 2726 2011-12-09 06:15:15Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnFinancialAccountTypeOnBankAccounts < ActiveRecord::Migration
  def self.up
    add_column :bank_accounts, :financial_account_type, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :bank_accounts, :financial_account_type
  end
end
