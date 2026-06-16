require 'test_helper'

class MmControllerTest < ActionDispatch::IntegrationTest

  def test_index
    sign_in admin
    get mm_path
    assert_response :success
    assert_equal '/mm', path
  end
end
