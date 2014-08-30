require 'test_helper'

class TaxesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => journal.id
    assert_response :success
    assert_template :update
  end

end
