require 'test_helper'

class Mm::BanksControllerTest < ActionController::TestCase

  def test_一覧
    @deleted = Bank.where(company_id: admin.employee.company_id).first
    @deleted.update_columns(deleted: true)

    sign_in admin
    get :index, params: {commit: '表示'}
    assert_response :success
    assert_template 'index'

    @banks = assigns(:banks)
    assert_not_empty @banks
    assert_not_includes @banks, @deleted, '削除された金融機関が含まれていないこと'
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
      post :create, params: {bank: bank_params}, xhr: true
      assert_response :success
      assert_template 'common/reload'
    end
  end

  def test_登録_入力エラー
    sign_in admin

    assert_no_difference('Bank.count') do
      post :create, params: {bank: invalid_bank_params}, xhr: true
      assert_response :success
      assert_template 'new'
    end
  end

  def test_参照
    sign_in admin
    get :show, params: {id: banks(:with_linked_accounts).id}, xhr: true
    assert_response :success
  end

  def test_編集
    sign_in admin
    get :edit, params: {id: bank.id}, xhr: true
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in admin
    patch :update, params: {id: bank.id, bank: bank_params.except(:code)}, xhr: true
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
    bank = banks(:without_linked_accounts)

    assert_no_difference 'Bank.count' do
      delete :destroy, params: {id: bank.id}
      assert_response :redirect
      assert_redirected_to action: 'index'
      assert bank.reload.deleted?
    end
  end

  def test_参照ありでは削除できない
    sign_in admin
    bank = banks(:with_linked_accounts)

    delete :destroy, params: {id: bank.id}
    assert_redirected_to action: 'index'
    assert_not bank.reload.deleted?
    assert flash[:is_error_message]
    assert_equal ERR_BANK_LINKED, flash[:notice]
  end

  def test_無効
    sign_in admin
    bank = banks(:without_linked_accounts)

    post :disable, params: {id: bank.id}
    assert_response :redirect
    assert_redirected_to action: 'index'
    assert bank.reload.disabled?
  end

  def test_参照ありでは無効化できない
    sign_in admin
    bank = banks(:with_linked_accounts)

    post :disable, params: {id: bank.id}
    assert_redirected_to action: 'index'
    assert_not bank.reload.disabled?
    assert flash[:is_error_message]
    assert_equal ERR_BANK_DISABLE_LINKED, flash[:notice]
  end

  def test_参照ありでは営業店を無効化できない
    sign_in admin
    bank = banks(:with_linked_accounts)
    office = bank_offices(:with_linked_accounts)

    patch :update, params: {
      id: bank.id,
      bank: {
        name: bank.name,
        bank_offices_attributes: {
          '0' => {id: office.id, code: office.code, name: office.name, disabled: true}
        }
      }
    }, xhr: true

    assert_response :success
    assert_template 'edit'
    assert flash[:is_error_message]
    assert_includes flash[:notice], ERR_BANK_OFFICE_DISABLE_LINKED
    assert_not bank.reload.disabled?
    assert_not office.reload.disabled?
  end

  def test_営業店舗追加
    sign_in admin
    get :add_bank_office, xhr: true
    assert_response :success
    assert_template 'banks/_bank_office_fields'
  end

end
