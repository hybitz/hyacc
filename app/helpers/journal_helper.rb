# coding: UTF-8
#
# $Id: journal_helper.rb 3164 2014-01-01 11:07:49Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module JournalHelper
  include HyaccConstants

  # 編集可能か
  def can_edit( jh )
    # 自動振替伝票は編集不可
    return false if is_auto( jh )
    true
  end
  
  # 削除可能か
  def can_delete( jh )
    # 台帳登録は削除不可
    if jh.slip_type == SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION
      return false
    end
    
    return can_edit( jh )
  end
  
  def colspan_of_account_details
    return 3 if branch_mode
    2
  end
  
  def colspan_of_account_details_for_show
    return 4 if branch_mode
    3
  end

  # 自動仕訳か
  def is_auto( jh )
    [SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE,
     SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE,
     SLIP_TYPE_AUTO_TRANSFER_EXPENSE,
     SLIP_TYPE_AUTO_TRANSFER_INTERNAL_TRADE,
     SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_COST,
     SLIP_TYPE_AUTO_TRANSFER_ALLOCATED_ASSETS,
     SLIP_TYPE_CARRY_FORWARD,
     SLIP_TYPE_DEEMED_TAX,
     SLIP_TYPE_DEPRECIATION,
     SLIP_TYPE_HOUSEWORK].include? jh.slip_type
  end
  
  def is_current_asset(account_id)
    # 流動資産科目か
    a = Account.get(account_id)
    # 資産の部
    a.is_current_assets?
  end
  
  def is_debt(account_id)
    a = Account.get(account_id)
    # 負債の部
    a.account_type == ACCOUNT_TYPE_DEBT
  end
  
  def is_real_cost(account_id)
    
    return false if account_id.nil?
    
    a = Account.get(account_id)
    
    if [ACCOUNT_CODE_HEAD_OFFICE_COST,
        ACCOUNT_CODE_HEAD_OFFICE_COST_SHARE].include?(a.code)
      return false
    end
    # 費用の部
    a.is_expense?
  end
  
  def can_allocate_assets(account_id, dc_type)
    # 資産配賦は貸方のみ
    return false if dc_type == DC_TYPE_DEBIT
    # 新規追加の場合
    return true if account_id.nil?
    # 科目により判断
    return is_current_asset(account_id)
  end
  
  def can_allocate_debt(account_id, dc_type)
    # 負債配賦は貸方のみ
    return false if dc_type == DC_TYPE_DEBIT
    # 新規追加の場合
    return true if account_id.nil?
    # 科目により判断
    return is_debt(account_id)
  end

  def can_allocate_cost( branch_id )
    return true unless branch_id.present?
    Branch.where(:parent_id => branch_id).present?
  end

  def style_for_details
    'display: none;' unless current_user.show_details
  end

  def message_for_details(show = nil)
    show = current_user.show_details if show.nil?

    if show
      '詳細を隠す'
    else
      '詳細を表示'
    end
  end
end
