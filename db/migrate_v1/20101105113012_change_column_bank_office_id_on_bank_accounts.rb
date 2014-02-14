# -*- encoding : utf-8 -*-
#
# $Id: 20101105113012_change_column_bank_office_id_on_bank_accounts.rb 2726 2011-12-09 06:15:15Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class ChangeColumnBankOfficeIdOnBankAccounts < ActiveRecord::Migration
  def self.up
    change_column :bank_accounts, :bank_office_id, :integer, :null=>true
  end

  def self.down
    change_column :bank_accounts, :bank_office_id, :integer, :null=>false
  end
end
