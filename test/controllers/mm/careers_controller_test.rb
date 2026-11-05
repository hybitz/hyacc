require 'test_helper'

class Mm::CareersControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_一覧_0件なら空の結果
    sign_in user
    Career.delete_all

    get :index
    assert_response :success
    assert_select '.alert-warning', text: '該当するデータが見つかりませんでした。'
    assert_select '.alert-info', count: 0
  end

  def test_一覧_受注先が論理削除のみで経歴も無ければ前提案内だけ
    sign_in user
    Career.delete_all
    Customer.where(is_order_entry: true).update_all(deleted: true)

    get :index
    assert_response :success
    assert_select '.alert-info', text: /業務経歴を追加するには受注先の登録が必要です/
    assert_select '.alert-info a[href=?]', mm_customers_path, text: '取引先管理へ'
    assert_select '.alert-warning', count: 0
    assert_select '.search', count: 0
    assert_select 'a.add', count: 0
  end

  def test_一覧_受注先なし・経歴あり・絞り込み0件でも検索と前提案内
    sign_in user
    Customer.where(is_order_entry: true).update_all(deleted: true)
    employee_id = Employee.where(deleted: false).where.not(id: Career.select(:employee_id)).pick(:id)
    assert employee_id

    get :index, params: { finder: { employee_id: employee_id } }
    assert_response :success
    assert_select '.search'
    assert_select '.alert-info', text: /業務経歴を追加するには受注先の登録が必要です/
    assert_select '.alert-info a[href=?]', mm_customers_path, text: '取引先管理へ'
    assert_select '.alert-warning', count: 0
    assert_select 'a.add', count: 0
  end

  def test_編集_論理削除された取引先も今の値として選択肢にある
    sign_in user
    c = career
    c.customer.update_columns(deleted: true)

    get :edit, xhr: true, params: {id: c.id}
    assert_response :success
    assert_includes assigns(:customers).map(&:id), c.customer_id
  end

  def test_参照
    sign_in user
    get :show, params: {id: career.id}, xhr: true
    assert_response :success
    assert_template :show
  end

  def test_追加
    sign_in user
    get :new, xhr: true
    assert_response :success
    assert_template :new
  end

  def test_追加_employee_idを渡すと従業員が設定される
    sign_in user
    employee = user.employee
    get :new, xhr: true, params: { employee_id: employee.id }
    assert_response :success
    assert_equal employee.id, assigns(:c).employee_id
  end

  def test_登録
    sign_in user
    post :create, xhr: true, params: {career: valid_career_params}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, xhr: true, params: {career: invalid_career_params}
    assert_response :success
    assert_template :new
  end

  def test_登録_入力エラー_論理削除された取引先は選択肢に戻さない
    sign_in user
    customer = Customer.where(is_order_entry: true, deleted: false).first
    assert customer
    customer.update_columns(deleted: true)

    post :create, xhr: true, params: {career: invalid_career_params.merge(customer_id: customer.id)}
    assert_response :success
    assert_template :new
    assert_not_includes assigns(:customers).map(&:id), customer.id
  end

  def test_編集
    sign_in user
    get :edit, xhr: true, params: {id: career.id}
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    patch :update, :xhr => true, :params => {:id => career.id, :career => valid_career_params}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    patch :update, :xhr => true, :params => {:id => career.id, :career => invalid_career_params}
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in user
    delete :destroy, :params => {:id => career.id}
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

end
