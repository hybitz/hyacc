require 'test_helper'

class Mm::CompaniesControllerTest < ActionController::TestCase

  def setup
    sign_in user
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:capital)
  end

  def test_ロゴの表示
    get :show_logo, :id => current_user.company_id
    assert_response :success
  end

  def test_事業区分の編集
    xhr :get, :edit, :id => current_user.company_id, :field => 'business_type'
    assert_response :success
    assert_template :edit_business_type
  end

  def test_ロゴの編集
    xhr :get, :edit, :id => current_user.company_id, :field => 'logo'
    assert_response :success
    assert_template :edit_logo
  end

  def test_管理者の編集
    xhr :get, :edit, :id => current_user.company_id, :field => 'admin'
    assert_response :success
    assert_template :edit_admin
  end

  def test_法人番号の編集
    xhr :get, :edit, :id => current_user.company_id, :field => 'enterprise_number'
    assert_response :success
    assert_template :edit_enterprise_number
  end
  
  def test_給与支払日の編集
    xhr :get, :edit, :id => current_user.company_id, :field => 'payday'
    assert_response :success
    assert_template :edit_payday
  end
  
  def test_更新
    xhr :patch, :update, :id => current_user.company_id, :company => valid_company_params
    assert_response :success
    assert_equal 'document.location.reload();', @response.body
  end

end
