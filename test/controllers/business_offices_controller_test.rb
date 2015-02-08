require 'test_helper'

class BusinessOfficesControllerTest < ActionController::TestCase

  def test_追加
    sign_in user
    xhr :get, :new
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in user
    xhr :post, :create, :business_office => valid_business_office_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    xhr :post, :create, :business_office => invalid_business_office_params
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => business_office.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => business_office.id, :business_office => valid_business_office_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    xhr :patch, :update, :id => business_office.id, :business_office => invalid_business_office_params
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in user
    delete :destroy, :id => business_office.id
    assert_response :redirect
    assert_redirected_to companies_path
  end

end
