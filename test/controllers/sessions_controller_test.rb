require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  def test_ログイン
    post :create, :user => {:login_id => user.login_id, :password => user.password}
    assert_response :redirect
    assert_redirected_to root_path
  end

end
