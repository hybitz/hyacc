require 'test_helper'

class SubAccountsControllerTest < ActionController::TestCase
  
  def test_Trac_145_地代家賃の一覧が正しく取得できること
    sign_in user
    get :index, :params => {:account_id => 26, :order => 'code'}, :format => 'json'
    assert_response :success
  end

  def test_index_勘定科目が寄付金のとき補助科目はその他が先頭になること
    sign_in user
    account = Account.find_by(code: ACCOUNT_CODE_DONATION)
    get :index, params: { account_id: account.id, order: 'code' }, format: 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal SUB_ACCOUNT_CODE_DONATION_OTHERS, SubAccount.find(json.first['id']).code
  end

  def test_index_勘定科目が寄付金以外のときは補助科目はcode順で返すこと
    sign_in user
    get :index, params: { account_id: 39, order: 'code' }, format: 'json'
    assert_response :success
    json = JSON.parse(response.body)
    sub_account_ids = json.map { |h| h['id'] }
    sub_accounts_by_id = SubAccount.where(id: sub_account_ids).index_by(&:id)
    codes = json.map { |h| sub_accounts_by_id[h['id'].to_i].code }
    assert_equal codes.sort, codes
  end
end
