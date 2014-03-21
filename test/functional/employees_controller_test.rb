require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_編集
    sign_in user
    get :edit, :id => employee.id, :format => 'js'
    assert_response :success
    assert_template :edit
  end

  def test_履歴の追加
    sign_in user
    get :add_employee_history, :format => 'js'
    assert_response :success
    assert_template :add_employee_history
  end

  def test_所属部門の追加
    sign_in user
    get :add_branch, :format => 'js'
    assert_response :success
    assert_template :add_branch
  end

  def test_更新
    sign_in user
    put :update, :id => employee.id, :format => 'js', :employee => valid_employee_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :id => employee.id, :format => 'js', :employee => invalid_employee_params
    assert_response :success
    assert_template :edit
  end

  def test_他の従業員を削除
    @employee = Employee.where('id <> ?', user.employee_id).first
    
    sign_in user
    delete :destroy, :id => @employee.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_自分を削除
    @employee = Employee.where('id = ?', user.employee_id).first
    
    sign_in user
    delete :destroy, :id => @employee.id
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'logout'
  end

end
