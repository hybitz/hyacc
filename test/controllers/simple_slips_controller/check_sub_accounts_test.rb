require 'test_helper'

class SimpleSlipsController::CheckSubAccountsTest < ActionController::TestCase

  def setup
    sign_in user
  end

  def test_一覧_取引先マスタが未登録
    Customer.delete_all
    get :index, params: {account_code: ACCOUNT_CODE_RECEIVABLE}
    assert_template "sub_accounts_required"
  end

end