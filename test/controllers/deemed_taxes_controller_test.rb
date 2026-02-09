require 'test_helper'

class DeemedTaxesControllerTest < ActionDispatch::IntegrationTest

  def test_一覧
    sign_in freelancer
    get deemed_taxes_path
    
    assert_response :success
    assert_template :index
  end

  def test_仕訳作成
    sign_in freelancer
    post deemed_taxes_path
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_簡易課税なら利用可
    assert @user = company_of_tax_simplified.users.first
    sign_in @user
    get deemed_taxes_path
    assert_response :success
  end

  def test_簡易課税でなければ利用不可
    assert @user = company_of_tax_general.users.first
    sign_in @user
    get deemed_taxes_path
    assert_response :forbidden
  end

end
