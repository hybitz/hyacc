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
    xhr :get, :new, :exemption => valid_exemption_params
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in admin
    xhr :post, :create, :exemption => valid_exemption_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_編集
    sign_in admin
    xhr :get, :edit, :id => exemption.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    xhr :patch, :update, :id => exemption.id, :exemption => valid_exemption_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_削除
    sign_in admin
    delete :destroy, :id => exemption.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
