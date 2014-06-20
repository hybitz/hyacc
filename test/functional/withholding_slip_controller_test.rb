require 'test_helper'

class WithholdingSlipControllerTest < ActionController::TestCase

  setup do
    #@request.session[:user_id] = users(:first).id
  end
  
  def test_should_get_list
    sign_in user
    get :list
    assert_response :success
  end

  def test_should_get_details_list
    sign_in user
    get :list, :commit => true, :finder => details_finder
    assert_response :success
  end

  def test_should_get_summary_list
    sign_in user
    get :list, :commit => true, :finder => summary_finder
    assert_response :success
  end
  
  def test_should_get_no_employee
    sign_in user
    get :list, :commit => true, :finder => no_employee_finder
    assert_response :success
  end
end
