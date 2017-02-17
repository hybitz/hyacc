require 'test_helper'

class TaxesControllerTest < ActionController::TestCase

  def test_消費税を税抜処理していなければ利用不可
    assert @user = company_of_tax_inclusive.users.first
    sign_in @user
    get :index
    assert_response :forbidden
  end

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_更新
    sign_in user
    patch :update, :xhr => true, :params => {:id => journal.id}
    assert_response :success
    assert_template :update
  end

end
