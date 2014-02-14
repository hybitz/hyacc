# -*- encoding : utf-8 -*-
#
# $Id: 20101105111044_update_financial_account_type_on_bank_accounts.rb 2726 2011-12-09 06:15:15Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateFinancialAccountTypeOnBankAccounts < ActiveRecord::Migration
  def self.up
    BankAccount.update_all("financial_account_type=1")
  end

  def self.down
  end
end
