# coding: UTF-8

require 'test_helper'

class CareersControllerTest < ActionController::TestCase

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
    post :create, :format => 'js', :career => valid_career_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, :format => 'js', :career => invalid_career_params
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    get :edit, :id => career.id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    put :update, :id => career.id, :format => 'js', :career => valid_career_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :id => career.id, :format => 'js', :career => invalid_career_params
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in user
    delete :destroy, :id => career.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
