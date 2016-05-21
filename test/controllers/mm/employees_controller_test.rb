require 'test_helper'

class Mm::EmployeesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => employee.id
    assert_response :success
    assert_template :edit
  end

  def test_履歴の追加
    sign_in user
    xhr :get, :add_employee_history
    assert_response :success
    assert_template :add_employee_history
  end

  def test_所属部門の追加
    sign_in user
    xhr :get, :add_branch
    assert_response :success
    assert_template '_branch_employee_fields'
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => employee.id, :employee => valid_employee_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    xhr :patch, :update, :id => employee.id, :employee => invalid_employee_params
    assert_response :success
    assert_template :edit
  end

  def test_他の従業員を削除
    assert @employee = Employee.where('id <> ?', user.employee.id).first

    sign_in user
    delete :destroy, :id => @employee.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_自分を削除
    sign_in user
    delete :destroy, :id => user.employee.id
    assert_response :redirect
    assert_redirected_to root_path
  end

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end

end