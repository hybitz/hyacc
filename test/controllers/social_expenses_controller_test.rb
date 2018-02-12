require 'test_helper'

class SocialExpensesControllerTest < ActionDispatch::IntegrationTest

  def test_個人事業主は利用不可
    sign_in freelancer
    get social_expenses_path
    assert_response :forbidden
  end

  def test_一覧
    sign_in user
    get social_expenses_path
    assert_response :success
    assert_equal '/social_expenses', path
  end

  def test_条件指定
    sign_in user
    get social_expenses_path, params: {
        commit: true,
        finder: {fiscal_year: current_company.current_fiscal_year_int, branch_id: 989}
      }
    assert_response :success
    assert_equal '/social_expenses', path
  end

end
