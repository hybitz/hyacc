require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  def test_参照
    sign_in user
    get :show, :xhr => true, :params => {:id => account.id}
    assert_response :success
  end

  def test_show_寄付金のとき補助科目JSONはその他が先頭であること
    sign_in user
    donation_account = Account.find_by(code: ACCOUNT_CODE_DONATION)

    get :show, xhr: true, params: { id: donation_account.id }
    assert_response :success

    json = JSON.parse(response.body)
    first = json['sub_accounts'].first
    assert_equal SUB_ACCOUNT_CODE_DONATION_OTHERS, SubAccount.find(first['id']).code
  end

  def test_show_寄付金以外のとき補助科目JSONはcode順であること
    sign_in user
    non_donation_account = Account.find_by(code: '2161')

    get :show, xhr: true, params: { id: non_donation_account.id }
    assert_response :success

    json = JSON.parse(response.body)
    sub_accounts = json['sub_accounts']
    by_id = SubAccount.where(id: sub_accounts.map { |h| h['id'] }).index_by(&:id)
    codes = sub_accounts.map { |h| by_id[h['id'].to_i].code }
    assert_equal codes.sort, codes
  end

end
