require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest

  def test_初期状態
    assert User.delete_all

    get root_path
    assert_response :redirect
    follow_redirect!
    assert_equal '/first_boot', path
  end

end
