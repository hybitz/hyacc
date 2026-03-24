require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  def test_参照
    sign_in user
    get :show, :xhr => true, :params => {:id => account.id}
    assert_response :success
  end

  def test_寄付金のとき補助科目並び替えフラグが真になること
    sign_in user
    donation_account = Account.find_by(code: ACCOUNT_CODE_DONATION)

    get :show, xhr: true, params: { id: donation_account.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json['requires_sub_accounts_reorder']
  end

  def test_寄付金以外のとき補助科目並び替えフラグが偽になること
    sign_in user
    non_donation_account = Account.find_by(code: '2161')

    get :show, xhr: true, params: { id: non_donation_account.id }
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal false, json['requires_sub_accounts_reorder']
  end

end
