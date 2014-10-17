require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include HyaccViewHelper

  def setup
    sign_in user
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:users)
  end

  def test_show
    xhr :get, :show, :id => user.id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_new
    xhr :get, :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:user)
  end

  def test_create
    assert_difference 'User.count' do
      xhr :post, :create, :user => {
        :login_id => 'zero',
        :password => 'zerozero',
        :email => 'test@example.com',
        :employee_attributes => {
          :company_id => current_user.company_id,
          :last_name => 'test_create', 
          :first_name => 'a', 
          :employment_date => '2009-01-01',
          :sex => 'M',
        }
      }
    end
 
    assert_response :success
    
    u = User.find_by_login_id('zero')
    assert_not_nil u
    assert_not_nil u.employee
    assert_equal 'test_create', u.employee.last_name
    assert_equal 'a', u.employee.first_name
    assert_equal 'M', u.employee.sex
    assert_equal '2009/01/01', format_date(u.employee.employment_date)
  end

  def test_edit
    xhr :get, :edit, :id => user.id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user)
    assert assigns(:user).valid?
  end

  def test_更新
    xhr :patch, :update, :id => user.id, :user => valid_user_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_他人を削除した場合_一覧に遷移すること
    assert_nothing_raised {
      User.find(2)
    }

    delete :destroy, :id => 2
    assert_response :redirect
    assert_redirected_to :action => 'index'

    assert User.find(2).deleted
  end

  def test_本人を削除した場合_ログアウトすること
    assert_nothing_raised {
      User.find(user.id)
    }

    delete :destroy, :id => user.id

    assert_response :redirect
    assert_redirected_to new_user_session_path
    assert User.find(user.id).deleted?
  end
end
