require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  def test_初期状態
    assert User.delete_all

    get :index
    assert_response :redirect
    assert_redirected_to first_boot_index_path
  end

end
