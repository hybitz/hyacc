# coding: UTF-8

require 'test_helper'

class SocialExpenseControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

end
