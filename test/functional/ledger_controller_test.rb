require 'test_helper'

class LedgerControllerTest < ActionController::TestCase

  setup do
    # fixtureで検索キーを設定していないので、ARを一旦保存
    JournalHeader.all.each{|jh| jh.save }

    sign_in users(:first)
  end

  def test_一覧
    # 一度GETでアクセスしてセッション上にファインダーを登録する
    get :index
    assert assigns(:ledgers).empty?, '最初のアクセスは検索条件を表示するだけ'

    get :index, :finder => {:account_id => 5}
    assert_equal( 12, assigns(:ledgers).length ) # 12ヶ月分のデータを取得
    
    num_journal_headers = JournalHeader.count( :conditions=>["finder_key rlike ? and ym = 200705", ".*-1311,[0-9]*,[0-9]*-.*"] )
    get :list_journals, :ym => 200705
    assert_equal( num_journal_headers, assigns(:ledgers).length )
  end
end
