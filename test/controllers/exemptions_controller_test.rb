require 'test_helper'

class ExemptionsControllerTest < ActionController::TestCase
  def test_初期表示
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end
end
