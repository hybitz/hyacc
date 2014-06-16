require 'test_helper'

class AssetsControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index, :format => 'js'
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    get :show, :id => asset.id, :format => 'js'
    assert_response :success
    assert_template :show
  end

  def test_編集
    sign_in user
    get :edit, :id => asset.id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    put :update, :id => asset.id, :format => 'js', :asset => valid_asset_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :id => asset.id, :format => 'js', :asset => invalid_asset_params
    assert_response :success
    assert_template :edit
  end

end
