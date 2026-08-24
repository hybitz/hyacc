require 'test_helper'

class Mm::InhabitantTaxesControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index, :params => {:finder => {:year=>'2009'}}
    assert_response :success
    assert assigns(:list).present?
  end

  def test_一覧_従業員で絞り込める
    sign_in admin
    get :index, :params => {:finder => {:year=>'2009', :employee_id => 1}}
    assert_response :success
    assert assigns(:list).present?
    assert assigns(:list).all? { |it| it.employee_id == 1 }
  end

  def test_アップロード
    sign_in admin
    post :confirm, params: {file: upload_file('inhabitant_tax.csv')}
    assert_template :confirm
    assert_equal 2, assigns(:list).size
    assert assigns(:linked)
  end

  def test_アップロード_未紐付け
    sign_in admin
    post :confirm, params: {file: upload_file('inhabitant_tax_unlinked.csv')}
    assert_template :confirm
    refute assigns(:linked)
    assert flash[:is_error_message]
    assert_equal '従業員マスタと紐づけできませんでした。従業員マスタに登録してください。', flash[:notice]
  end

  def test_登録
    sign_in admin
    file = upload_file('inhabitant_tax.csv')
    finder = {:year => '2016'}
    list, = InhabitantCsv.load(file, admin.employee.company)
    inhabitant = {}
    list.each_with_index do |ic, index|
      inhabitant[index] = {:employee_id => ic.employee_id, :amounts => ic.amounts}
    end
    post :create, :params => {:inhabitant_csv => inhabitant, :finder => finder}
    assert_redirected_to action: 'index', finder: {year: 2016}
    assert_equal 14, InhabitantTax.where("ym like ?", "2016%").size
    assert_equal 10, InhabitantTax.where("ym like ?", "2017%").size
  end

  def test_登録_未紐付けは拒否される
    sign_in admin
    assert_no_difference('InhabitantTax.count') do
      post :create, :params => {
        :inhabitant_csv => {0 => {:amounts => '19000,18200,18200,18200,18200,18200,18200,18200,18200,18200,18200,18200'}},
        :finder => {:year => '2016'}
      }
    end
    assert_redirected_to action: 'index', finder: {year: 2016}
    assert flash[:is_error_message]
    assert_equal '従業員マスタと紐づけできませんでした。従業員マスタに登録してください。', flash[:notice]
  end

  def test_登録_データが空の場合は拒否される
    sign_in admin
    assert_no_difference('InhabitantTax.count') do
      post :create, :params => {:finder => {:year => '2016'}}
    end
    assert_redirected_to action: 'index', finder: {year: 2016}
    assert flash[:is_error_message]
    assert_equal '取り込む住民税データがありません。', flash[:notice]
  end

  def test_登録_不正な金額は保存されない
    sign_in admin
    assert_no_difference('InhabitantTax.count') do
      post :create, :params => {
        :inhabitant_csv => {
          0 => {
            :employee_id => 1,
            :amounts => 'x,18200,18200,18200,18200,18200,18200,18200,18200,18200,18200,18200'
          }
        },
        :finder => {:year => '2016'}
      }
    end
    assert_redirected_to action: 'index', finder: {year: 2016}
    assert flash[:is_error_message]
    assert_equal ['金額は数値で入力してください'], flash[:notice]
  end

  def test_登録_amountsが無い場合は保存されない
    sign_in admin
    assert_no_difference('InhabitantTax.count') do
      post :create, :params => {
        :inhabitant_csv => {0 => {:employee_id => 1}},
        :finder => {:year => '2016'}
      }
    end
    assert_redirected_to action: 'index', finder: {year: 2016}
    assert flash[:is_error_message]
    assert_equal ['金額を入力してください'], flash[:notice]
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
      :inhabitant_tax => {:amount => 10000}
    }
    assert_response :success
    assert_template :show
  end

  def test_削除
    sign_in admin
    target = InhabitantTax.first

    assert_difference('InhabitantTax.count', -1) do
      delete :destroy, :xhr => true, :params => {:id => target.id}
    end
    assert_response :success
    assert_template 'common/reload'
  end

end
