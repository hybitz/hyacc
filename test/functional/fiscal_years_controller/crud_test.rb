require 'test_helper'

class FiscalYearsController::CrudTest < ActionController::TestCase

  def setup
    sign_in user
  end

  def test_一覧
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:fiscal_years)
  end

  def test_編集
    xhr :get, :edit, :id => Company.first.current_fiscal_year.id
    assert_not_nil assigns(:fiscal_year)
    assert_response :success
    assert_template :edit
  end

  def test_update_current_fiscal_year
    c = Company.find(1)
    assert_equal 2009, c.fiscal_year
    
    lv = c.lock_version

    xhr :post, :update_current_fiscal_year,
      :company_id => c.id,
      :c => {:fiscal_year => 2008, :lock_version => lv}
    assert_response :success
    assert_template 'common/reload'
        
    c = Company.find(1)
    assert_equal 2008, c.fiscal_year
    
    xhr :post, :update_current_fiscal_year,
      :company_id => c.id,
      :c => {:fiscal_year => 2009, :lock_version => lv}
    assert_response :success
    assert_template :edit_current_fiscal_year
    
    c = Company.find(1)
    assert_equal 2008, c.fiscal_year
  end
end
