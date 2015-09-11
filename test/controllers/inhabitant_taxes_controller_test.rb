require 'test_helper'

class InhabitantTaxesControllerTest < ActionController::TestCase

  def test_個人事業主は利用不可
    sign_in freelancer
    get :index
    assert_response :forbidden
  end

  def test_一覧
    sign_in user
    get :index, :commit=>'表示', :finder=>{:year=>'2009'}
    assert_response :success
    assert_not_nil assigns(:list)
  end

  def test_新規
    sign_in user
    get :new
    assert_response :success
    assert_template :new
  end

  def test_アップロード
    sign_in user
    post :confirm, :file => upload_file('inhabitant_tax.csv')
    assert_template :confirm
    assert_equal 2, assigns(:list).size
  end
  
  def test_登録
    
  end
  
  def test_参照
    sign_in user
    xhr :get, :show, :id => InhabitantTax.first.id
    assert_response :success
    assert_template :show
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => InhabitantTax.first.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => InhabitantTax.first.id,
        :inhabitant_tax => {:employee_id => 2, :amount => 10000}
    assert_response :success
    assert_template :show
  end

  def test_削除
    sign_in user
    assert_difference('InhabitantTax.count', -1) do
      delete :destroy, :id => InhabitantTax.first.id
    end
    assert_redirected_to :action=>'index'
  end
  
end
