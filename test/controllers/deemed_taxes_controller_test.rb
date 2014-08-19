require 'test_helper'

class DeemedTaxesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in freelancer
    get :index
    
    assert_response :success
    assert_template :index
  end

  def test_仕訳作成
    sign_in freelancer
    post :create
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
