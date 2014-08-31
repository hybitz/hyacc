require 'test_helper'

class PensionsControllerTest < ActionController::TestCase

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end

end
