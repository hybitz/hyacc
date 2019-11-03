require 'test_helper'

class Mm::SimpleSlipTemplatesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in admin
    get :new, :xhr => true
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:simple_slip_template)
  end

  def test_登録
    sign_in admin
    post :create, params: {simple_slip_template: simple_slip_template_params}, xhr: true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in admin
    post :create, params: {simple_slip_template: invalid_simple_slip_template_params}, xhr: true
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in admin
    get :edit, params: {id: simple_slip_template.id}, xhr: true
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:simple_slip_template)
  end

  def test_更新
    sign_in admin
    patch :update, params: {id: simple_slip_template.id, simple_slip_template: simple_slip_template_params}, xhr: true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in admin
    patch :update, params: {id: simple_slip_template.id, simple_slip_template: invalid_simple_slip_template_params}, xhr: true
    assert_response :success
    assert_template 'edit'
  end

  def test_削除
    sign_in admin
    delete :destroy, params: {id: simple_slip_template.id}
    assert_response :redirect
    assert_redirected_to action: 'index'
  end

end
