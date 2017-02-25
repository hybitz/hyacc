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
    get :show, :params => {:id => asset.id}, :xhr => true
    assert_response :success
    assert_template :show
  end

  def test_編集
    sign_in user
    get :edit, :params => {:id => asset.id}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    patch :update, :params => {:id => asset.id, :asset => valid_asset_params}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    patch :update, :params => {:id => asset.id, :asset => invalid_asset_params}, :xhr => true
    assert_response :success
    assert_template :edit
  end

end
