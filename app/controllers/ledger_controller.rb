# coding: UTF-8
#
# $Id: ledger_controller.rb 3357 2014-02-07 02:54:34Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class LedgerController < Base::HyaccController
  view_attribute :title => '元帳'
  view_attribute :finder, :class => LedgerFinder, :only => :index
  view_attribute :ym_list, :only => :index
  view_attribute :accounts, :only => :index
  view_attribute :branches, :only => :index

  def index
    # 月別累計を取得
    @ledgers = finder.list
    
    # 年月の指定がある場合（損益計算書・貸借対照表からの遷移）、指定月の伝票を取得
    ym = params[:ym].to_i
    if ym > 0
      target_index = get_ym_index( finder.start_month_of_fiscal_year, ym )
      @ledgers.delete_at( target_index )
      @ledgers.insert( target_index, *finder.list_journals( ym ) )
    end
    
    # 前年度末残高を取得
    @last_year_balance = finder.get_last_year_balance
    setup_view_attributes
  end

  def list_journals
    @ledgers = finder.list_journals( params[:ym].to_i )
    render :partial=>'list_journals'
  end

  private

  def setup_view_attributes
    if finder.account_id.present?
      @account = Account.get(finder.account_id)
      @sub_accounts = load_sub_accounts(finder.account_id)
    end
  end
end
