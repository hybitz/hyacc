require 'test_helper'

class Mm::BanksControllerTest < ActionController::TestCase

  def test_一覧
    sign_in admin
    get :index, :params => {:commit => '表示'}
    assert_response :success
    assert_not_nil assigns(:banks)
  end

  def test_追加
    sign_in admin
    get :new, :xhr => true
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in admin

    assert_difference('Bank.count') do
      post :create, :params => {:bank => valid_bank_params}, :xhr => true
      assert_response :success
      assert_template 'common/reload'
    end
  end

  def test_登録_入力エラー
    sign_in admin

    assert_no_difference('Bank.count') do
      post :create, :params => {:bank => invalid_bank_params}, :xhr => true
      assert_response :success
      assert_template 'new'
    end
  end

  def test_参照
    sign_in admin
    get :show, :params => {:id => banks(:data1).id}, :xhr => true
    assert_response :success
  end

  def test_編集
    sign_in admin
    get :edit, :params => {:id => bank.id}, :xhr => true
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, params: {id: bank.id, bank: valid_bank_params.except(:code)}, xhr: true
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in admin
    patch :update, params: {id: bank.id, bank: invalid_bank_params.except(:code)}, xhr: true
    assert_response :success
    assert_template 'edit'
  end

  def test_削除
    sign_in admin

    assert_no_difference 'Bank.count' do
      delete :destroy, :params => {:id => banks(:data1).id}
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end

  def test_営業店舗追加
    sign_in admin
    get :add_bank_office, :xhr => true
    assert_response :success
    assert_template 'banks/_bank_office_fields'
  end

end
