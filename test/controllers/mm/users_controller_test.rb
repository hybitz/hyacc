require 'test_helper'

class Mm::UsersControllerTest < ActionController::TestCase
  include HyaccViewHelper

  def test_index
    sign_in freelancer
    get :index

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:users)
  end

  def test_show
    sign_in admin
    get :show, :params => {:id => user.id}, :xhr => true

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_new
    sign_in admin
    get :new, :xhr => true

    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:user)
  end

  def test_create_with_valid_branch_employees_params
    sign_in admin

    assert_difference 'User.count' do
      assert_difference 'BranchEmployee.count', 2 do
        post :create, xhr: true, params: user_params_with_valid_branch_employees
      end
    end
 
    assert_response :success
    
    u = User.find_by_login_id('zero')
    assert_not_nil u
    assert_not_nil u.employee
    assert_equal 'test_create', u.employee.last_name
    assert_equal 'a', u.employee.first_name
    assert_equal 'M', u.employee.sex
    assert_equal '2009-01-01', u.employee.employment_date.to_s
    assert_equal '2000-01-01', u.employee.birth.to_s
    assert_equal 2, u.employee.default_branch.id
  end

  def test_create_with_invalid_branch_employees_params
    sign_in admin

    assert_no_difference 'User.count' do
      assert_no_difference 'BranchEmployee.count' do
        post :create, xhr: true, params: user_params_with_invalid_branch_employees
      end
    end
    assert assigns(:user).invalid?
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in admin
    get :edit, :xhr => true, :params => {:id => user.id}

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_更新
    sign_in admin
    patch :update, :xhr => true, :params => {:id => user.id, :user => user_params}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_他人を削除した場合_一覧に遷移すること
    sign_in admin
    delete :destroy, :params => {:id => user.id}
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert user.reload.deleted?
  end

  def test_本人を削除した場合_ログアウトすること
    sign_in admin
    delete :destroy, :params => {:id => admin.id}

    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert admin.reload.deleted?
  end
end
