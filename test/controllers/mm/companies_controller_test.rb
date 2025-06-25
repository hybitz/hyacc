require 'test_helper'

class Mm::CompaniesControllerTest < ActionController::TestCase

  def setup
    sign_in admin
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to [:mm, current_company]
  end

  def test_参照
    get :show, params: {id: current_company.id}
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:capital)
  end

  def test_ロゴの表示
    get :show_logo, :params => {:id => current_company.id}
    assert_response :success
  end

  def test_事業区分の編集
    get :edit, :xhr => true, :params => {:id => current_company.id, :field => 'business_type'}
    assert_response :success
    assert_template :edit_business_type
  end

  def test_ロゴの編集
    get :edit, :xhr => true, :params => {:id => current_company.id, :field => 'logo'}
    assert_response :success
    assert_template :edit_logo
  end

  def test_管理者の編集
    get :edit, :xhr => true, :params => {:id => current_company.id, :field => 'admin'}
    assert_response :success
    assert_template :edit_admin
  end

  def test_法人番号の編集
    get :edit, xhr: true, params: {id: current_company.id, field: 'enterprise_number'}
    assert_response :success
    assert_template :edit_enterprise_number
  end
  
  def test_労働番号の編集
    get :edit, xhr: true, params: {id: current_company.id, field: 'labor_insurance_number'}
    assert_response :success
    assert_template :edit_labor_insurance_number
  end

  def test_給与支払日の編集
    get :edit, :xhr => true, :params => {:id => current_company.id, :field => 'pay_day_definition'}
    assert_response :success
    assert_template :edit_pay_day_definition
  end

  def test_退職金積立の開始時期
    get :edit, xhr: true, params: {id: current_company.id, field: 'retirement_savings_after'}
    assert_response :success
    assert_template :edit_retirement_savings_after
  end
  
  def test_更新
    patch :update, xhr: true, params: {id: current_company.id, company: company_params}
    assert_response :success
    assert_equal 'document.location.reload();', @response.body
  end

end
