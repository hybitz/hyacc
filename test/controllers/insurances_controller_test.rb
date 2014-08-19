require 'test_helper'

class InsurancesControllerTest < ActionController::TestCase
  
  def setup
    @request.session[:user_id] = users(:first).id
  end

  def test_should_get_index
    get :index
    assert_response :success
  end
end
