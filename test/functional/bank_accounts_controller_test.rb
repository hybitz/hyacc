# coding: UTF-8

require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase

  def test_一覧
    @request.session[:user_id] = 4
    
    get :index

    assert_response :success
  end

end
