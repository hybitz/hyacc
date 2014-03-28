require 'test_helper'

# 個人事業主の会計年度のテスト
class FiscalYearsController::PersonalTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = User.find(4).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:fiscal_years)
  end
  
  def test_confirm_carry_forward
    fy = FiscalYear.find(12)
    assert_equal CLOSING_STATUS_OPEN, fy.closing_status

    xhr :get, :confirm_carry_forward, :id => fy.id

    assert_response :success
    assert_template :confirm_carry_forward
    assert_not_nil assigns(:fy)
  end

  def test_carry_forward
    fy = FiscalYear.find(10)
    assert_equal CLOSING_STATUS_OPEN, fy.closing_status

    xhr :post, :carry_forward, :id => fy.id,
      :lock_version => fy.lock_version,
      :journalize_housework => 0

    assert_response :success
    assert_template 'common/reload'
  end
end
