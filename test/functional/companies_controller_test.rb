require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase

  def setup
    sign_in users(:first)
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:capital)
  end
end
