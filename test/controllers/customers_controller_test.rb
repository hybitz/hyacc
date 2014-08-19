require 'test_helper'

class CustomersControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    xhr :get, :show, :id => customer.id
    assert_response :success
    assert_template :show
  end

  def test_名称追加
    sign_in user
    get :add_customer_name
    assert_response :success
    assert_template 'customers/_customer_name_fields'
  end

  def test_追加
    sign_in user
    xhr :get, :new
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in user
    xhr :post, :create, :customer => valid_customer_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    xhr :post, :create, :customer => invalid_customer_params
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => customer.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    xhr :put, :update, :id => customer.id, :customer => valid_customer_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    xhr :put, :update, :id => customer.id, :customer => invalid_customer_params
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
