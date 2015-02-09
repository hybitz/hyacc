require 'test_helper'

class BankOfficesControllerTest < ActionController::TestCase

  setup do
  end
  
  def test_一覧
    sign_in user
    get :index, :format => 'json'
    assert_response :success
  end

end
