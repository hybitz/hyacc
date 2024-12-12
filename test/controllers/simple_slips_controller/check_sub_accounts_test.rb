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

  def test_一覧_金融口座マスタが未登録
    BankAccount.delete_all
    get :index, params: {account_code: ACCOUNT_CODE_ORDINARY_DIPOSIT}
    assert_template "sub_accounts_required"
  end

  def test_一覧_地代家賃マスタが未登録
    Rent.delete_all
    get :index, params: {account_code: ACCOUNT_CODE_RENT}
    assert_template "sub_accounts_required"
  end

end