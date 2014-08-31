require 'test_helper'

class HouseworksControllerTest < ActionController::TestCase

  def test_個人事業主でなければ利用不可
    sign_in user
    get :index
    assert_response :forbidden
  end

  def test_一覧
    sign_in freelancer
    get :index
    assert_response :success
    assert_template :index
  end

end
