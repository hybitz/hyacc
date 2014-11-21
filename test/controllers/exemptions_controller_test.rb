require 'test_helper'

class ExemptionsControllerTest < ActionController::TestCase
  def test_初期表示
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in user
    get :new, :format => 'js'
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in user
    post :create, :format => 'js', :exemption => valid_exemption_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in user
    get :edit, :id => exemption.id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    put :update, :id => exemption.id, :format => 'js', :exemption => valid_exemption_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_削除
    sign_in user
    delete :destroy, :id => exemption.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end


end
