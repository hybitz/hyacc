require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  def test_参照
    sign_in user
    get :show, :xhr => true, :params => {:id => account.id}
    assert_response :success
  end

end
