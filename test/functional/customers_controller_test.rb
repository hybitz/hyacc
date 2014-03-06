# coding: UTF-8

require 'test_helper'

class CustomersControllerTest < ActionController::TestCase

  def test_一覧
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
    post :create, :format => 'js', :customer => valid_customer_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, :format => 'js', :customer => invalid_customer_params
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    get :edit, :id => customer.id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    put :update, :id => customer.id, :format => 'js', :customer => valid_customer_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :id => customer.id, :format => 'js', :customer => invalid_customer_params
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in user
    delete :destroy, :id => customer.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
