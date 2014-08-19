require 'test_helper'

# 仮負債精算の機能テスト
class DebtsControllerTest < ActionController::TestCase

  def setup
    sign_in users(:user2)
  end
  
  # 仮負債一覧表示
  def test_index
    get :index, :finder => {:fiscal_year => '2009', :branch_id => '3'}, :commit => '表示'

    assert_response :success
    assert_template :index
    assert_not_nil assigns(:finder)
    assert_equal 2, assigns(:debts).size
  end
  
  # 仮負債個別精算
  def test_update
    num_journal_headers = JournalHeader.count
    
    post :create, :journal_header_id => '6466',:branch_id => '3',
      :account_id=>'5',:sub_account_id => '1',
      :ymd=>'2009-09-24'
    assert_response :success
    assert_equal num_journal_headers + 1, JournalHeader.count
    
    # 仕訳内容の確認
    list = JournalHeader.where(:ym => 200909, :day => 24)
    assert_equal 1, list.length, "自動仕訳が１つ作成される"
    jh = list[0]
    assert_equal 6466, jh.transfer_from_id
    assert_equal 4, jh.journal_details.length
  end
  
  # 仮負債個別精算（エラー）
  def test_update_fail
    num_journal_headers = JournalHeader.count
    
    post :create, :journal_header_id => '6466', :branch_id => '3',
      :account_id=>'5', :sub_account_id => '',
      :ymd=>'2009-09-24'
    assert_response :internal_server_error
    assert_equal num_journal_headers, JournalHeader.count
  end
  
end
