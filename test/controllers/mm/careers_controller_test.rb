require 'test_helper'

class Mm::CareersControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    get :show, params: {id: career.id}, xhr: true
    assert_response :success
    assert_template :show
  end

  def test_追加
    sign_in user
    get :new, xhr: true
    assert_response :success
    assert_template :new
  end

  def test_追加_employee_idを渡すと従業員が設定される
    sign_in user
    employee = user.employee
    get :new, xhr: true, params: { employee_id: employee.id }
    assert_response :success
    assert_equal employee.id, assigns(:c).employee_id
  end

  def test_登録
    sign_in user
    post :create, xhr: true, params: {career: valid_career_params}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, xhr: true, params: {career: invalid_career_params}
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in user
    get :edit, xhr: true, params: {id: career.id}
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    patch :update, :xhr => true, :params => {:id => career.id, :career => valid_career_params}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    patch :update, :xhr => true, :params => {:id => career.id, :career => invalid_career_params}
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in user
    delete :destroy, :params => {:id => career.id}
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
