require 'test_helper'

class InhabitantTaxesControllerTest < ActionController::TestCase

  setup do
    @request.session[:user_id] = users(:first).id
  end

  def test_一覧
    get :index, :commit=>'表示', :finder=>{:year=>'2009'}
    assert_response :success
    assert_not_nil assigns(:list)
  end

  def test_新規
    get :new
    assert_response :success
    assert_template :new
  end

  def test_登録
    post :create, :file => upload_file('inhabitant_tax.csv')
    assert_response :redirect
    assert_redirected_to :action => "index"
    assert_equal 48, assigns(:list).size
  end
  
  def test_参照
    xhr :get, :show, :id => InhabitantTax.first.id
    assert_response :success
    assert_template :show
  end

  def test_編集
    xhr :get, :edit, :id => InhabitantTax.first.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    xhr :patch, :update, :id => InhabitantTax.first.id,
        :inhabitant_tax => {:employee_id => 2, :amount => 10000}
    assert_response :success
    assert_template :show
  end

  def test_削除
    assert_difference('InhabitantTax.count', -1) do
      delete :destroy, :id => InhabitantTax.first.id
    end
    assert_redirected_to :action=>'index'
  end
  
end
