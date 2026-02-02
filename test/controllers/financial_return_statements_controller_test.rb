require 'test_helper'

class FinancialReturnStatementsControllerTest < ActionController::TestCase

  def test_6_有価証券の内訳書
    sign_in user
    get :index, params: {commit: true, finder: investment_finder}
    assert_response :success
    assert_template 'financial_return_statements/investment_securities/00000000'
  end

  def test_9_買掛金の内訳書
    sign_in user
    get :index, params: {commit: true, finder: trade_account_payable_finder}
    assert_response :success
    assert_template 'financial_return_statements/trade_account_payable/00000000'
  end

  def test_15_地代家賃等の内訳書
    sign_in user
    get :index, params: {commit: true, finder: rent_finder}
    assert_response :success
  assert_template 'financial_return_statements/rent/00000000'
  end

  def test_別表四_所得の金額の計算に関する明細書
    sign_in user
    get :index, params: {commit: true, finder: appendix_04_finder}
    assert_response :success
    assert_template 'financial_return_statements/appendix_04/00000000'
  end

  def test_別表四_所得の金額の計算に関する明細書_20170401
    sign_in user
    get :index, params: {commit: true, finder: appendix_04_finder.merge(fiscal_year: 2017)}
    assert_response :success
    assert_template 'financial_return_statements/appendix_04/20170401'
  end

  def test_別表5_1_利益積立金額及び資本金等の計算に関する明細書
    sign_in user
    get :index, params: {commit: true, finder: appendix_05_01_finder}
    assert_response :success
    assert_template 'financial_return_statements/appendix_05_01/00000000'
  end

  def test_別表14_2_寄附金の損金算入に関する明細書
    sign_in user
    fiscal_year = user.employee.company.current_fiscal_year_int
    get :index, params: {commit: true, finder: appendix_14_02_finder(fiscal_year)}
    assert_response :success
    assert_template 'financial_return_statements/appendix_14_02/00000000'
    assert_instance_of Reports::Appendix1402Model, assigns(:model)
  end

  def test_別表5_2_租税公課の納付状況等に関する明細書
    sign_in user
    get :index, params: {commit: true, finder: appendix_05_02_finder}
    assert_response :success
    assert_template 'financial_return_statements/appendix_05_02/00000000'
  end

  def test_別表15_交際費等の損金算入に関する明細書
    sign_in user
    get :index, params: {commit: true, finder: appendix_15_finder.merge(fiscal_year: 2022)}
    assert_response :success
    assert_template 'financial_return_statements/appendix_15/20140401'
  end

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end
end
