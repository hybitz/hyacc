# -*- encoding : utf-8 -*-
#
# $Id: 20101127163426_update_is_tax_account_on_accounts.rb 2727 2011-12-09 06:17:17Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class UpdateIsTaxAccountOnAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    # 法人税等
    ct = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    if ct
      ct.is_tax_account = true
      ct.save!
    end
    
    # 未払法人税等
    ctp = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE)
    if ctp
      ctp.is_tax_account = true
      ctp.save!
    end
  end

  def self.down
  end
end
