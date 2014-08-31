require 'test_helper'

class HouseworkDetailsControllerTest < ActionController::TestCase

  def test_個人事業主でなければ利用不可
    sign_in user
    xhr :get, :new, :housework_id => housework.id
    assert_response :forbidden
  end

  def test_追加
    sign_in freelancer
    xhr :get, :new, :housework_id => housework.id
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in freelancer
    xhr :post, :create,
        :housework_id => housework.id,
        :housework_detail => {:account_id => expense_account.id, :business_ratio => 80}
    assert_response :success
    assert_template 'common/reload'
  end

end
