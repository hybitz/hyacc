require 'test_helper'

class LedgersControllerTest < ActionController::TestCase

  def setup
    # fixtureで検索キーを設定していないので、ARを一旦保存
    Journal.all.each{|jh| assert jh.save }
  end

  def test_一覧
    sign_in user
    get :index, :params => {:finder => {:fiscal_year => 2007, :account_id => 5}}
    assert_equal 12, assigns(:ledgers).length, '12ヶ月分のデータを取得していること'
  end

  def test_参照
    num_journals = Journal.where('finder_key rlike ? and ym = ?', '.*-1311,[0-9]*,[0-9]*-.*', 200705).count

    sign_in user
    get :show, :xhr => true, :params => {:id => 200705, :finder => {:fiscal_year => 2007, :account_id => 5}}
    assert_equal num_journals, assigns(:ledgers).length
  end

end
