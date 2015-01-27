require 'test_helper'

class LedgersControllerTest < ActionController::TestCase

  setup do
    # fixtureで検索キーを設定していないので、ARを一旦保存
    JournalHeader.all.each{|jh| jh.save }

    sign_in user
  end

  def test_一覧
    get :index, :finder => {:fiscal_year => 2007, :account_id => 5}
    assert_equal 12, assigns(:ledgers).length, '12ヶ月分のデータを取得していること'
    
    num_journal_headers = JournalHeader.where('finder_key rlike ? and ym = ?', '.*-1311,[0-9]*,[0-9]*-.*', 200705).count
    xhr :get, :show, :id => 200705
    assert_equal num_journal_headers, assigns(:ledgers).length
  end
end
