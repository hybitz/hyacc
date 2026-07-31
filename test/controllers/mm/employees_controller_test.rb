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

  def test_登録_給与振込口座が不完全なときはエラーが出る
    sign_in admin
    branch = admin.employee.default_branch
    post :create, xhr: true, params: {
      employee: employee_params.merge(
        branch_employees_attributes: {
          '0' => { branch_id: branch.id, default_branch: true }
        },
        employee_bank_account_attributes: {
          bank_id: bank.id,
          bank_office_id: '',
          code: '1234567'
        }
      )
    }

    assert_response :success
    assert_template :new
    assert flash[:is_error_message]
    assert_equal ['支店名称を入力してください'], flash[:notice]
  end

  def test_更新_給与振込口座が不完全なら口座が削除される
    sign_in admin
    e = employee
    account = e.employee_bank_account
    assert account

    patch :update, xhr: true, params: {
      id: e.id,
      employee: employee_params.merge(
        employee_bank_account_attributes: {
          id: account.id,
          bank_id: account.bank_id,
          bank_office_id: '',
          code: account.code
        }
      )
    }

    assert_response :success
    assert_template 'common/reload'
    assert_nil e.reload.employee_bank_account
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
    post :disable, params: {id: employee.id}
    assert_redirected_to action: 'index'
  end

  def test_他の従業員を削除
    assert @employee = Employee.where('id <> ?', admin.employee.id).first

    sign_in admin
    delete :destroy, params: {id: @employee.id}
    assert_redirected_to action: 'index'
  end

  def test_ログイン可能な管理権限を持つユーザーが1人のとき_自分自身を無効にできない
    sign_in admin
    post :disable, params: {id: admin.employee.id}

    assert_redirected_to action: 'index'
    assert_not admin.employee.reload.disabled?
    assert flash[:is_error_message]
    assert_equal [ERR_LAST_ACTIVE_ADMIN_DISABLE], flash[:notice]
  end

  def test_ログイン可能な管理権限を持つユーザーが1人のとき_自分自身を削除できない
    sign_in admin
    delete :destroy, params: {id: admin.employee.id}

    assert_redirected_to action: 'index'
    assert_not admin.employee.reload.deleted?
    assert flash[:is_error_message]
    assert_equal [ERR_LAST_ACTIVE_ADMIN_DELETE], flash[:notice]
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_自分自身を無効にできる
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    sign_in admin
    post :disable, params: {id: admin.employee.id}

    assert_redirected_to root_path
    assert admin.employee.reload.disabled?
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_自分自身を削除できる
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    sign_in admin
    delete :destroy, params: {id: admin.employee.id}

    assert_redirected_to root_path
    assert admin.employee.reload.deleted?
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_他のadminを無効にできる
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    sign_in admin
    post :disable, params: {id: other_admin.employee.id}

    assert_redirected_to action: 'index'
    assert other_admin.employee.reload.disabled?
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_他のadminを削除できる
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    sign_in admin
    delete :destroy, params: {id: other_admin.employee.id}

    assert_redirected_to action: 'index'
    assert other_admin.employee.reload.deleted?
  end

end
