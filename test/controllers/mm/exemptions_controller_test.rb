require 'test_helper'

class Mm::ExemptionsControllerTest < ActionController::TestCase

  def test_初期表示
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in admin
    get :new, :params => {:exemption => valid_exemption_params}, :xhr => true
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in admin
    post :create, :params => {:exemption => valid_exemption_params}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in admin
    get :edit, :params => {:id => exemption.id}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, :params => {:id => exemption.id, :exemption => valid_exemption_params}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_削除
    sign_in admin
    delete :destroy, :params => {:id => exemption.id}
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
