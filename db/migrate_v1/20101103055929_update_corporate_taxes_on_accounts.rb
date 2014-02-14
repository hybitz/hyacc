# -*- encoding : utf-8 -*-
#
# $Id: 20101103055929_update_corporate_taxes_on_accounts.rb 2725 2011-12-09 06:14:40Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateCorporateTaxesOnAccounts < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    a = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    return unless a
    
    a.sub_account_type = SUB_ACCOUNT_TYPE_CORPORATE_TAX
    a.account_control.sub_account_editable = false
    a.save!
    a.account_control.save!
    
    sa = SubAccount.new
    sa.account_id = a.id
    sa.sub_account_type = SUB_ACCOUNT_TYPE_CORPORATE_TAX
    sa.code = '100'
    sa.name = '法人税'
    sa.save!
    
    sa = SubAccount.new
    sa.account_id = a.id
    sa.sub_account_type = SUB_ACCOUNT_TYPE_CORPORATE_TAX
    sa.code = '200'
    sa.name = '道府県民税'
    sa.save!
    
    sa = SubAccount.new
    sa.account_id = a.id
    sa.sub_account_type = SUB_ACCOUNT_TYPE_CORPORATE_TAX
    sa.code = '300'
    sa.name = '市町村民税'
    sa.save!
    
  end

  def self.down
  end
end
