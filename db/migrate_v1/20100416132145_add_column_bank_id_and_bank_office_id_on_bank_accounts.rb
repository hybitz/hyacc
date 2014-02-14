# -*- encoding : utf-8 -*-
#
# $Id: 20100416132145_add_column_bank_id_and_bank_office_id_on_bank_accounts.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnBankIdAndBankOfficeIdOnBankAccounts < ActiveRecord::Migration
  require 'active_record/fixtures'
  def self.up
    add_column :bank_accounts, :bank_id, :integer, :null=>false
    add_column :bank_accounts, :bank_office_id, :integer, :null=>false
    
    # カラム情報を最新にする
    BankAccount.reset_column_information
    # データ削除
    BankAccount.delete_all
    # データの投入
    dir = File.join(File.dirname(__FILE__), "fixtures/20100416132145")
    Fixtures.create_fixtures(dir, "bank_accounts")
  end

  def self.down
    remove_column :bank_accounts, :bank_id
    remove_column :bank_accounts, :bank_office_id
  end
end
