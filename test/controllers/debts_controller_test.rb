require 'test_helper'

# 仮負債精算の機能テスト
class DebtsControllerTest < ActionController::TestCase

  def setup
    sign_in users(:user2)
  end
  
  def test_一覧
    get :index, :params => {:finder => {:fiscal_year => '2009', :branch_id => '3'}, :commit => '表示'}

    assert_response :success
    assert_template :index
    assert_not_nil assigns(:finder)
    assert_equal 2, assigns(:debts).size
  end
  
  def test_仮負債個別精算
    num_journals = Journal.count
    
    post :create, :params => {:journal_id => '6466',:branch_id => '3',
      :account_id=>'5',:sub_account_id => '1',
      :ymd=>'2009-09-24'
    }
    assert_response :success
    assert_equal num_journals + 1, Journal.count
    
    # 仕訳内容の確認
    list = Journal.where(:ym => 200909, :day => 24)
    assert_equal 1, list.length, "自動仕訳が１つ作成される"
    jh = list[0]
    assert_equal 6466, jh.transfer_from_id
    assert_equal 4, jh.journal_details.length
  end
  
  # 仮負債個別精算（エラー）
  def test_update_fail
    num_journals = Journal.count
    
    post :create, :params => {
      :journal_id => '6466', :branch_id => '3',
      :account_id=>'5', :sub_account_id => '',
      :ymd=>'2009-09-24'
    }
    assert_response :internal_server_error
    assert_equal num_journals, Journal.count
  end

end
