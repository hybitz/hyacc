require 'test_helper'

class HouseworkControllerTest < ActionController::TestCase

  def test_一覧
    sign_in freelancer
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in freelancer
    get :new, :format => 'js', :housework_id => housework.id
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in freelancer
    post :create, :format => 'js',
        :hwd => {:housework_id => housework.id, :account_id => expense_account.id, :business_ratio => 80}
    assert_response :success
    assert_template 'common/reload'
  end

end
