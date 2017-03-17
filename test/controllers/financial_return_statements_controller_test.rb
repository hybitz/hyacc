require 'test_helper'

class FinancialReturnStatementsControllerTest < ActionController::TestCase

  def test_6_有価証券の内訳書
    sign_in user
    get :index, :params => {:commit => true, :finder => investment_finder}
    assert_response :success
    assert_template :investment_securities
  end

  def test_9_買掛金の内訳書
    sign_in user
    get :index, :params => {:commit => true, :finder => trade_account_payable_finder}
    assert_response :success
    assert_template :trade_account_payable
  end

  def test_15_地代家賃等の内訳書
    sign_in user
    get :index, :params => {:commit => true, :finder => rent_finder}
    assert_response :success
    assert_template :rent
  end

  def test_別表四_所得の金額の計算に関する明細書
    sign_in user
    get :index, :params => {:commit => true, :finder => income_finder}
    assert_response :success
    assert_template :income
  end

  def test_別表5_1_利益積立金額及び資本金等の計算に関する明細書
    sign_in user
    get :index, :params => {:commit => true, :finder => surplus_reserve_and_capital_stock_finder}
    assert_response :success
    assert_template :surplus_reserve_and_capital_stock
  end

  def test_別表5_2_租税公課の納付状況等に関する明細書
    sign_in user
    get :index, :params => {:commit => true, :finder => tax_and_dues_finder}
    assert_response :success
    assert_template :tax_and_dues
  end

  def test_別表15_交際費等の損金算入に関する明細書
    sign_in user
    get :index, :params => {:commit => true, :finder => social_expense_finder}
    assert_response :success
    assert_template :social_expense
  end

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end
end
