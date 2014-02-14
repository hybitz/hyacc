# coding: UTF-8
#
# $Id: ledger_controller_test.rb 3165 2014-01-01 11:37:37Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class LedgerControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
    
    # fixtureで検索キーを設定していないので、ARを一旦保存
    JournalHeader.find(:all).each{ |jh| jh.save }
  end

  def test_一覧
    # 一度GETでアクセスしてセッション上にファインダーを登録する
    get :index
    assert_equal 0, assigns(:ledgers).length, '最初のアクセスは検索条件を表示するだけ'

    get :index, :finder => {
      :account_id => 5
    }
    assert_equal( 12, assigns(:ledgers).length ) # 12ヶ月分のデータを取得
    
    num_journal_headers = JournalHeader.count( :conditions=>["finder_key rlike ? and ym = 200705", ".*-1311,[0-9]*,[0-9]*-.*"] )
    get :list_journals, :ym => 200705
    assert_equal( num_journal_headers, assigns(:ledgers).length )
  end
end
