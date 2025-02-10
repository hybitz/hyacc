require 'test_helper'

class FiscalYearsController::CrudTest < ActionController::TestCase

  def setup
    sign_in user
  end

  def test_一覧
    get :index
    assert_response :success
    assert_template :index
    fiscal_years = assigns(:fiscal_years)
    assert_not_nil fiscal_years
    assert_equal fiscal_years.pluck(:fiscal_year).sort.reverse, fiscal_years.pluck(:fiscal_year)
  end

  def test_登録
    post :create, xhr: true, params: {fiscal_year: fiscal_year_params(user: user)}
    assert_response :success
    assert_template :new
  end

  def test_登録_エラー
    post :create, :xhr => true, :params => {:fiscal_year => invalid_fiscal_year_params}
    assert_response :success
    assert_template :new
  end

  def test_編集
    get :edit, :xhr => true, :params => {:id => current_company.current_fiscal_year.id}
    assert_not_nil assigns(:fiscal_year)
    assert_response :success
    assert_template :edit
  end

  def test_更新
    patch :update, xhr: true, params: {
        id: current_company.current_fiscal_year.id,
        fiscal_year: fiscal_year_params(user: user).except(:fiscal_year)
    }
    assert_response :success
    assert_template 'common/reload'
  end

  def test_update_current_fiscal_year
    c = Company.find(1)
    assert_equal 2009, c.fiscal_year
    
    lv = c.lock_version

    post :update_current_fiscal_year, :xhr => true, :params => {
      :company_id => c.id,
      :c => {:fiscal_year => 2008, :lock_version => lv}
    }
    assert_response :success
    assert_template 'common/reload'
        
    c = Company.find(1)
    assert_equal 2008, c.fiscal_year
    
    post :update_current_fiscal_year, :xhr => true, :params => {
      :company_id => c.id,
      :c => {:fiscal_year => 2009, :lock_version => lv}
    }
    assert_response :success
    assert_template :edit_current_fiscal_year
    
    c = Company.find(1)
    assert_equal 2008, c.fiscal_year
  end
end
