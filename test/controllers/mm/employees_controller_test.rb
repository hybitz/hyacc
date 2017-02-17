require 'test_helper'

class Mm::EmployeesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_編集
    sign_in admin
    get :edit, :params => {:id => employee.id}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_所属部門の追加
    sign_in admin
    get :add_branch, :xhr => true
    assert_response :success
    assert_template '_branch_employee_fields'
  end

  def test_更新
    sign_in admin
    patch :update, :params => {:id => employee.id, :employee => valid_employee_params}, :xhr => true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in admin
    patch :update, :params => {:id => employee.id, :employee => invalid_employee_params}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_他の従業員を削除
    assert @employee = Employee.where('id <> ?', admin.employee.id).first

    sign_in admin
    delete :destroy, :params => {:id => @employee.id}
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_自分を削除
    sign_in admin
    delete :destroy, :params => {:id => admin.employee.id}
    assert_response :redirect
    assert_redirected_to root_path
  end

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end

end
