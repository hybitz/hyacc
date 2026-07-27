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

  def test_更新_複数バリデーションエラー時はalertで改行連結される
    invalid_params = {
      labor_insurance_number: 'abc'
    }

    company = Company.find(current_company.id)
    company.attributes = invalid_params
    assert company.invalid?
    expected_messages = company.errors.full_messages
    assert_equal 2, expected_messages.size

    patch :update, xhr: true, params: {id: current_company.id, company: invalid_params}

    assert_response :success
    assert_match(/\Aalert\('/, @response.body)
    assert_match(/'\);\z/, @response.body)
    assert_includes @response.body, '\n'
    assert_not_includes @response.body, '["'
    expected_messages.each do |message|
      assert_includes @response.body, message
    end
  end

end
