# -*- encoding : utf-8 -*-
#
# $Id: 20101110003422_change_column_code_on_bank_accounts.rb 2726 2011-12-09 06:15:15Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnCodeOnBankAccounts < ActiveRecord::Migration
  def self.up
    change_column :bank_accounts, :code, :string, :limit=>10
  end

  def self.down
  end
end
