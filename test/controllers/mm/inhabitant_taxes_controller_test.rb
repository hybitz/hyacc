require 'test_helper'

class Mm::InhabitantTaxesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index, :params => {:commit => '表示', :finder => {:year=>'2009'}}
    assert_response :success
    assert_not_nil assigns(:list)
  end

  def test_新規
    sign_in admin
    get :new
    assert_response :success
    assert_template :new
  end

  def test_アップロード
    sign_in admin
    post :confirm, params: {file: upload_file('inhabitant_tax.csv')}
    assert_template :confirm
    assert_equal 2, assigns(:list).size
  end
  
  def test_登録
    sign_in admin
    file = upload_file('inhabitant_tax.csv')
    finder = {:year => '2016'}
    list, linked = InhabitantCsv.load(file.tempfile, admin.employee.company)
    inhabitant = {}
    list.each_with_index do |ic, index|
      inhabitant[index] = {:employee_id => ic.employee_id, :amounts => ic.amounts}
    end
    post :create, :params => {:inhabitant_csv => inhabitant, :finder => finder}
    assert_redirected_to action: 'index',  finder: finder
    assert_equal 14, InhabitantTax.where("ym like ?", "2016%").size
    assert_equal 10, InhabitantTax.where("ym like ?", "2017%").size
  end
  
  def test_参照
    sign_in admin
    get :show, :params => {:id => InhabitantTax.first.id}, :xhr => true
    assert_response :success
    assert_template :show
  end

  def test_編集
    sign_in admin
    get :edit, :params => {:id => InhabitantTax.first.id}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, :xhr => true, :params => {:id => InhabitantTax.first.id,
      :inhabitant_tax => {:employee_id => 2, :amount => 10000}
    }
    assert_response :success
    assert_template :show
  end

  def test_削除
    sign_in admin
    assert_difference('InhabitantTax.count', -1) do
      delete :destroy, :params => {:id => InhabitantTax.first.id}
    end
    assert_redirected_to :action => 'index', finder: { year: 2025 }
  end
  
end
