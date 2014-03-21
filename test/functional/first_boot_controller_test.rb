require 'test_helper'

class FirstBootControllerTest < ActionController::TestCase

  def test_初期画面
    User.delete_all

    get :index
    assert_response :success
    assert_template :index
  end

  def test_既に初期登録済み
    assert User.count > 0

    get :index
    assert_response :redirect
    assert_redirected_to :controller => 'login'
  end

  def test_個人事業主として登録
    User.delete_all

    post :create,
        :c => {:name => 'テスト会社', :founded_date => Date.today, :type_of => COMPANY_TYPE_PERSONAL},
        :fy => {:tax_management_type => TAX_MANAGEMENT_TYPE_EXEMPT},
        :e => {:last_name => '山田', :first_name => '花子', :sex => SEX_TYPE_F},
        :u => {:login_id => 'test', :password => 'testtest'}

    assert_response :redirect
    assert_redirected_to :action => 'ready'
  end

  def test_株式会社として登録
    User.delete_all

    post :create,
        :c => {:name => 'テスト会社', :founded_date => Date.today, :type_of => COMPANY_TYPE_COLTD},
        :fy => {:tax_management_type => TAX_MANAGEMENT_TYPE_EXCLUSIVE},
        :e => {:last_name => '山田', :first_name => '花子', :sex => SEX_TYPE_F},
        :u => {:login_id => 'test', :password => 'testtest'}

    assert_response :redirect
    assert_redirected_to :action => 'ready'
  end

  def test_登録_入力エラー
    User.delete_all

    post :create,
        :c => {:name => '', :founded_date => Date.today, :type_of => COMPANY_TYPE_PERSONAL},
        :fy => {:tax_management_type => TAX_MANAGEMENT_TYPE_EXEMPT},
        :e => {:last_name => '', :first_name => '', :sex => SEX_TYPE_F},
        :u => {:login_id => '', :password => ''}

    assert_response :success
    assert_template :index
  end

end
