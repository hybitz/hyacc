require 'test_helper'

class HouseworksControllerTest < ActionController::TestCase

  def test_一覧
    sign_in freelancer
    get :index
    assert_response :success
    assert_template :index
  end

end
