# -*- encoding : utf-8 -*-
#
# $Id: 20101127081700_update_journal_details_for_corporate_tax.rb 2727 2011-12-09 06:17:17Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
# 補助科目IDの振り直し
class UpdateJournalDetailsForCorporateTax < ActiveRecord::Migration
  include HyaccConstants

  def self.up
    a = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES)
    return unless a

    # 法人税
    sa = SubAccount.find(:first, :conditions=>['account_id=? and sub_account_type=? and code=?', a.id, SUB_ACCOUNT_TYPE_CORPORATE_TAX, '100'])
    if sa
      JournalDetail.update_all(['sub_account_id=?', CORPORATE_TAX_TYPE_CORPORATE_TAX],
          ['account_id=? and sub_account_id=?', a.id, sa.id])
    end
    
    # 道府県民税
    sa = SubAccount.find(:first, :conditions=>['account_id=? and sub_account_type=? and code=?', a.id, SUB_ACCOUNT_TYPE_CORPORATE_TAX, '200'])
    if sa
      JournalDetail.update_all(['sub_account_id=?', CORPORATE_TAX_TYPE_PREFECTURAL_TAX],
          ['account_id=? and sub_account_id=?', a.id, sa.id])
    end
    
    # 市町村民税
    sa = SubAccount.find(:first, :conditions=>['account_id=? and sub_account_type=? and code=?', a.id, SUB_ACCOUNT_TYPE_CORPORATE_TAX, '300'])
    if sa
      JournalDetail.update_all(['sub_account_id=?', CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX],
          ['account_id=? and sub_account_id=?', a.id, sa.id])
    end
  end

  def self.down
  end
end
