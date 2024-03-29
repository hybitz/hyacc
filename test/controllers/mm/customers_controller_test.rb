require 'test_helper'

class Mm::CustomersControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in admin
    get :show, params: {id: customer.id}, xhr: true
    assert_response :success
    assert_template :show
  end

  def test_追加
    sign_in admin
    get :new, :xhr => true
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in admin

    assert_difference 'Customer.count', 1 do
      post :create, params: {customer: valid_customer_params}, xhr: true
      assert_response :success
      assert_template 'common/reload'
    end
  end

  def test_登録_入力エラー
    sign_in admin

    assert_no_difference 'Customer.count' do
      post :create, :params => {:customer => invalid_customer_params}, :xhr => true
      assert_response :success
      assert_template :new
    end
  end

  def test_編集
    sign_in admin
    get :edit, :params => {:id => customer.id}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, :params => {:id => customer.id, :customer => valid_customer_params.except(:code)}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in admin
    patch :update, :params => {:id => customer.id, :customer => invalid_customer_params.except(:code)}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in admin

    assert_no_difference 'Customer.count' do
      delete :destroy, :params => {:id => customer.id}
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end

end
