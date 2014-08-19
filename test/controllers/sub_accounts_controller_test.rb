require 'test_helper'

class SubAccountsControllerTest < ActionController::TestCase
  
  def test_Trac_145_地代家賃の一覧が正しく取得できること
    sign_in user
    get :index, :format => 'json', :account_id => 26, :order => 'code'
    assert_response :success
  end
  
end
