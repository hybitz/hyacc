require 'test_helper'

class Bs::InvestmentsControllerTest < ActionController::TestCase
  
  def setup
    sign_in user
  end

  def test_一覧
    get :index
    assert_response :success
  end

  def test_検索
    get :index, params: {finder: {fiscal_year: 2016, bank_account_id: 3}}
    assert_response :success
  end

  def test_追加
    get :new, xhr: true
    assert_response :success
  end
    
  def test_should_create_investment
    assert_difference('Investment.count') do
      post :create, :xhr => true, :params => {
          investment: {yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1',
            buying_or_selling: '1', for_what: '1', shares: '20',
            trading_value: '100000', charges: '1080'}
           }
      assert_response :success
      assert_template 'common/reload'
    end
    assert_equal '有価証券情報を追加しました。', flash[:notice]
  end

  def test_手数料が0円でも追加と更新ができること
    assert_difference('Investment.count') do
      post :create, :xhr => true, :params => {
          investment: {yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1',
            buying_or_selling: '1', for_what: '1', shares: '20',
            trading_value: '100000', charges: '0'}
           }
      assert_response :success
      assert_template 'common/reload'
    end
    assert_equal '有価証券情報を追加しました。', flash[:notice]

    assert_no_difference('Investment.count') do
      patch :update, :xhr => true, :params => {
          investment: {yyyymmdd: '2016-03-27', bank_account_id: bank_account.id, customer_id: '1',
            buying_or_selling: '1', for_what: '1', shares: '20',
            trading_value: '100000', charges: '0'}, id: Investment.last.id
           }
      assert_response :success
      assert_template 'common/reload'
    end
    assert_equal '有価証券情報を更新しました。', flash[:notice]
  end

  def test_not_related
    JournalDetail.first.update(account_id: Account.find_by(code: ACCOUNT_CODE_TRADING_SECURITIES).id)
    get :not_related
    assert_response :success
  end

  def test_更新_エラー
    assert_no_difference('Investment.count') do
      patch :update, :xhr => true, :params => {
          investment: {yyyymmdd: '2015-03-27', bank_account_id: '3', customer_id: '1',
            buying_or_selling: '1', for_what: '1', shares: '0',
            trading_value: '240000', charges: '0'}, id: 1
           }
      assert_response :success
      assert_template 'edit'
    end
  end

end
