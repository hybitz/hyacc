require 'test_helper'

class CareerStatementControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_参照
    sign_in user
    get :show, :id => user.id
    assert_response :success
    assert_template :show
  end

end
