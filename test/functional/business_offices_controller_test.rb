# coding: UTF-8

require 'test_helper'

class BusinessOfficesControllerTest < ActionController::TestCase

  def test_追加
    sign_in user
    get :new, :format => 'js'
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in user
    post :create, :format => 'js', :business_office => valid_business_office_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, :format => 'js', :business_office => invalid_business_office_params
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    get :edit, :id => business_office.id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    put :update, :id => business_office.id, :format => 'js', :business_office => valid_business_office_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :id => business_office.id, :format => 'js', :business_office => invalid_business_office_params
    assert_response :success
    assert_template :edit
  end

end
