require 'test_helper'

class Mv::DepreciationRatesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

end
