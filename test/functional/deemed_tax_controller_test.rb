require 'test_helper'

class DeemedTaxControllerTest < ActionController::TestCase

  def test_一覧
    sign_in freelancer
    get :index
    
    assert_response :success
    assert_template :index
  end

  def test_仕訳作成
    sign_in freelancer
    post :create_journal
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
