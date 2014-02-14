# -*- encoding : utf-8 -*-
#
# $Id: 20100412005243_add_column_personal_only_on_accounts.rb 2127 2010-04-13 13:42:16Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class AddColumnPersonalOnlyOnAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    add_column :accounts, :personal_only, :boolean, :null=>false, :default=>false
    
    Account.reset_column_information
    return if Account.find(:all).size == 0
    Company.find(:all).each do |c|
      unless c.type_of_personal
        p '個人事業主ではないので科目追加はキャンセルします。'
        return
      end
    end
  
    
    # 元入金
    a = Account.find_by_code(ACCOUNT_CODE_PERSONAL_CAPITAL)
    unless a
      a = Account.new
      a.code = ACCOUNT_CODE_PERSONAL_CAPITAL
      a.name = '元入金'
      a.dc_type = DC_TYPE_CREDIT
      a.account_type = ACCOUNT_TYPE_CAPITAL
      a.deleted = false
      a.display_order = 1
      a.parent_id = Account.find_by_code(ACCOUNT_CODE_CAPITAL).id
      a.journalizable = true
      a.system_required = true
      a.trade_type = TRADE_TYPE_EXTERNAL
      a.is_settlement_report_account = true
      a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
      a.tax_type = TAX_TYPE_NONTAXABLE
      a.depreciable = false
      a.is_trade_account_payable = false
    end
    a.personal_only = true
    a.save!

    # 事業主借
    a = Account.find_by_code(ACCOUNT_CODE_DEBT_TO_OWNER)
    unless a
      a = Account.new
      a.code = ACCOUNT_CODE_DEBT_TO_OWNER
      a.name = '事業主借'
      a.dc_type = DC_TYPE_CREDIT
      a.account_type = ACCOUNT_TYPE_CAPITAL
      a.deleted = false
      a.display_order = 2
      a.parent_id = Account.find_by_code(ACCOUNT_CODE_CAPITAL).id
      a.journalizable = true
      a.system_required = true
      a.trade_type = TRADE_TYPE_EXTERNAL
      a.is_settlement_report_account = true
      a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
      a.tax_type = TAX_TYPE_NONTAXABLE
      a.depreciable = false
      a.is_trade_account_payable = false
    end
    a.personal_only = true
    a.save!

    # 事業主貸
    a = Account.find_by_code(ACCOUNT_CODE_CREDIT_BY_OWNER)
    unless a
      a = Account.new
      a.code = ACCOUNT_CODE_CREDIT_BY_OWNER
      a.name = '事業主貸'
      a.dc_type = DC_TYPE_DEBIT
      a.account_type = ACCOUNT_TYPE_ASSET
      a.deleted = false
      a.display_order = 3
      a.parent_id = Account.find_by_code(ACCOUNT_CODE_ASSETS).id
      a.journalizable = true
      a.system_required = true
      a.trade_type = TRADE_TYPE_EXTERNAL
      a.is_settlement_report_account = true
      a.sub_account_type = SUB_ACCOUNT_TYPE_NORMAL
      a.tax_type = TAX_TYPE_NONTAXABLE
      a.depreciable = false
      a.is_trade_account_payable = false
    end
    a.personal_only = true
    a.save!

  end

  def self.down
    a = Account.find_by_code(ACCOUNT_CODE_PERSONAL_CAPITAL)
    a.destroy if a
    a = Account.find_by_code(ACCOUNT_CODE_DEBT_TO_OWNER)
    a.destroy if a
    a = Account.find_by_code(ACCOUNT_CODE_CREDIT_BY_OWNER)
    a.destroy if a
    remove_column :accounts, :personal_only
  end
end
