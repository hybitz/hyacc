# -*- encoding : utf-8 -*-
#
# $Id: 20101127082738_delete_corporate_tax_sub_accounts.rb 2727 2011-12-09 06:17:17Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
# 法人税等の補助科目を削除
class DeleteCorporateTaxSubAccounts < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    SubAccount.delete_all(['sub_account_type=?', SUB_ACCOUNT_TYPE_CORPORATE_TAX])
  end

  def self.down
  end
end
