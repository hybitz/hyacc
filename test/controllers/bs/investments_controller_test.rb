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
end
