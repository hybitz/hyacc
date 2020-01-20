require 'test_helper'

class Mm::BusinessOfficesControllerTest < ActionController::TestCase

  def test_追加
    sign_in admin
    get :new, :xhr => true
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in admin
    post :create, xhr: true, params: {business_office: business_office_params}
    assert_response :success
    assert_template 'common/reload'
    assert @bo = assigns(:bo)
    assert_equal admin.employee.company_id, @bo.company_id
  end

  def test_登録_入力エラー
    sign_in admin
    post :create, :xhr => true, :params => {:business_office => invalid_business_office_params}
    assert_response :success
    assert_template :new
  end

  def test_編集
    sign_in admin
    get :edit, :xhr => true, :params => {:id => business_office.id}
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, xhr: true, params: {id: business_office.id, business_office: business_office_params}
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in admin
    patch :update, :xhr => true, :params => {:id => business_office.id, :business_office => invalid_business_office_params}
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in admin

    assert_no_difference 'BusinessOffice.count' do
      delete :destroy, :params => {:id => business_office.id}
    end

    assert_response :redirect
    assert_redirected_to mm_companies_path
  end

end
