require 'test_helper'

class InsurancesControllerTest < ActionController::TestCase

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end
  
  def test_should_get_index
    sign_in user
    get :index
    assert_response :success
  end
end
