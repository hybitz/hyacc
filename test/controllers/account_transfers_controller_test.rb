require 'test_helper'

class AccountTransfersControllerTest < ActionController::TestCase

  def test_初期画面の表示
    sign_in freelancer
    get :index
    assert_response :success
  end

  def test_複数明細が一括で更新できること
    assert_equal 29, JournalDetail.find(32).account_id
    assert_equal 2, JournalDetail.find(33).account_id
    assert_equal 24, JournalDetail.find(44).account_id
    assert_equal 5, JournalDetail.find(45).account_id
    assert_equal 29, JournalDetail.find(56).account_id
    assert_equal 2, JournalDetail.find(57).account_id

    sign_in freelancer

    post :update_details, :commit => '一括振替',
        :finder => finder_params,
        :form=>{
          "details"=>{
            "jh_15_lv_3_jd_32"=>"1",
            "jh_21_lv_5_jd_44"=>"1",
            "jh_27_lv_3_jd_56"=>"1",
          }
        }
      
    assert_response :redirect
    assert_redirected_to :action => 'index', :finder => finder_params, :commit => true
    assert_equal "科目を一括振替しました。", flash[:notice]

    assert_equal 3, JournalDetail.find(32).account_id
    assert_equal 2, JournalDetail.find(33).account_id
    assert_equal 3, JournalDetail.find(44).account_id
    assert_equal 5, JournalDetail.find(45).account_id
    assert_equal 3, JournalDetail.find(56).account_id
    assert_equal 2, JournalDetail.find(57).account_id
  end

  def test_楽観ロックが無効な場合に更新できないこと
    sign_in freelancer

    post :update_details, :commit=>"一括変更",
        :finder => finder_params,
        :form => {"details"=>{"jh_21_lv_4_jd_44"=>"1"}}
      
    assert_response :redirect
    assert_redirected_to :action => 'index', :finder => finder_params, :commit => true
    assert_equal ERR_STALE_OBJECT, flash[:notice]
  end

  def test_自動仕訳が更新できないこと
    sign_in freelancer

    post :update_details, :commit=>"一括変更",
        :finder => finder_params,
        :form=>{"details"=>{"jh_16_lv_3_jd_35"=>"1"}}
      
    assert_response :redirect
    assert_redirected_to :action => 'index', :finder => finder_params, :commit => true
    assert_equal ERR_INVALID_ACTION, flash[:notice]
  end
  
  def test_資産が関連している明細が更新できないこと
    sign_in user

    post :update_details, :commit => '一括変更',
        :finder => {:to_account_id => 3},
        :form => {"details"=>{"jh_6300_lv_0_jd_19025"=>"1"}}
      
    assert_response :redirect
    assert_redirected_to :action => 'index', :finder => finder_params, :commit => true
    assert_equal ERR_INVALID_ACTION, flash[:notice]
  end

  private

  def finder_params
    {:to_account_id => 3}
  end

end
