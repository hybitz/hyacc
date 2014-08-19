require 'test_helper'

class FinancialStatementsControllerTest < ActionController::TestCase

  def test_損益計算書_月別
    sign_in user
    get :index, :commit => true, :finder => pl_monthly_finder
    assert_response :success
    assert_template :pl_monthly
  end

  def test_損益計算書_年間
    sign_in user
    get :index, :commit => true, :finder => pl_yearly_finder
    assert_response :success
    assert_template :pl_yearly
  end

  def test_貸借対照表_月別
    sign_in user
    get :index, :commit => true, :finder => bs_monthly_finder
    assert_response :success
    assert_template :bs_monthly
  end

  def test_貸借対照表_年間
    sign_in user
    get :index, :commit => true, :finder => bs_yearly_finder
    assert_response :success
    assert_template :bs_yearly
  end

end
