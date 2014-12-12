require 'test_helper'

class Bs::AssetsControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    xhr :get, :show, :id => asset.id
    assert_response :success
    assert_template :show
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => asset.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => asset.id, :asset => valid_asset_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    xhr :patch, :update, :id => asset.id, :asset => invalid_asset_params
    assert_response :success
    assert_template :edit
  end

end
