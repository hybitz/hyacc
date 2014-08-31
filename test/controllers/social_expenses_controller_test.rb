require 'test_helper'

class SocialExpensesControllerTest < ActionController::TestCase

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

end
