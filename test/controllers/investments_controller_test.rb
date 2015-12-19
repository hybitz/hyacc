require 'test_helper'

class InvestmentsControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index, :commit => true
    assert_response :success
  end

end
