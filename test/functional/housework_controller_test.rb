require 'test_helper'

class HouseworkControllerTest < ActionController::TestCase

  def test_一覧
    sign_in freelancer
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in freelancer
    get :new, :format => 'js', :fiscal_year => freelancer.company.current_fiscal_year.fiscal_year
    assert_response :success
    assert_template :new
  end

end
