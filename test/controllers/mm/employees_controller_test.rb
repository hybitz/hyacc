require 'test_helper'

class Mm::EmployeesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in admin
    get :show, params: {id: user.id}, xhr: true
    assert_response :success
    assert_template :show
  end

  def test_追加
    sign_in admin
    get :new, xhr: true
    assert_response :success
    assert_template :new
  end
    
  def test_登録
    sign_in admin
    post :create, params: {employee: employee_params}, xhr: true
    assert_response :success
    assert_template 'common/reload'

    e = assigns(:e)
    assert_equal employee_params[:full_time], e.full_time
    assert_equal employee_params[:duty_description], e.duty_description
    assert_equal employee_params[:relationship_to_representative], e.relationship_to_representative
    assert_equal employee_params[:representative_or_family_type], e.representative_or_family_type
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
    patch :update, params: {id: employee.id, employee: employee_params}, xhr: true
    assert_response :success
    assert_template 'common/reload'

    e = assigns(:e)
    assert_equal employee_params[:full_time], e.full_time
    assert_equal employee_params[:duty_description], e.duty_description
    assert_equal employee_params[:relationship_to_representative], e.relationship_to_representative
    assert_equal employee_params[:representative_or_family_type], e.representative_or_family_type
  end

  def test_更新_入力エラー
    sign_in admin
    patch :update, params: {id: employee.id, employee: invalid_employee_params}, xhr: true
    assert_response :success
    assert_template :edit
  end

  def test_無効
    sign_in admin
    target_user = employee.user
    assert_not target_user.deleted?

    post :disable, params: {id: employee.id}
    assert_response :redirect
    assert_redirected_to action: 'index'
    assert employee.reload.disabled?
    assert target_user.reload.deleted?
  end

  def test_他の従業員を削除
    assert @employee = Employee.where('id <> ?', admin.employee.id).where(disabled: false).first!
    @employee.update_column(:disabled, true)

    sign_in admin
    delete :destroy, params: {id: @employee.id}
    assert_response :redirect
    assert_redirected_to action: 'index'
    assert @employee.reload.deleted?
  end

  def test_無効化前の削除は拒否される
    assert @employee = Employee.where('id <> ?', admin.employee.id).where(disabled: false).first!

    sign_in admin
    delete :destroy, params: {id: @employee.id}

    assert_response :redirect
    assert_redirected_to action: 'index'
    assert_not @employee.reload.deleted?
    assert flash[:is_error_message]
    assert_equal ERR_EMPLOYEE_NEEDS_DISABLE_BEFORE_DELETE, flash[:notice]
  end

  def test_管理者である従業員は削除できない
    sign_in admin
    delete :destroy, params: {id: admin.employee.id}

    assert_response :redirect
    assert_redirected_to action: 'index'
    assert_not admin.employee.reload.deleted?
    assert_not admin.reload.deleted?
    assert flash[:is_error_message]
    assert_equal ERR_ADMIN_USER_CANNOT_DELETE, flash[:notice]
  end

  def test_管理者である従業員は無効にできない
    sign_in admin
    post :disable, params: {id: admin.employee.id}

    assert_response :redirect
    assert_redirected_to action: 'index'
    assert_not admin.employee.reload.disabled?
    assert_not admin.reload.deleted?
    assert flash[:is_error_message]
    assert_equal ERR_ADMIN_USER_CANNOT_DISABLE, flash[:notice]
  end

end
