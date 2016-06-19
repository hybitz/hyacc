require 'test_helper'

class Mm::BankAccountsControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in user
    xhr :get, :new
    assert_response :success
    assert_template :new
  end
  
  def test_登録
    sign_in user
    xhr :post, :create, :bank_account => valid_bank_account_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    xhr :post, :create, :bank_account => invalid_bank_account_params
    assert_response :success
    assert_template :new
  end
  
  def test_編集
    sign_in user
    xhr :get, :edit, :id => bank_account.id
    assert_response :success
    assert_template :edit
  end
  
  def test_更新
    sign_in user
    xhr :patch, :update, :id => bank_account.id, :bank_account => valid_bank_account_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    xhr :patch, :update, :id => bank_account.id, :bank_account => invalid_bank_account_params
    assert_response :success
    assert_template :edit
  end

  def test_削除
    sign_in user
    delete :destroy, :id => bank_account.id
    assert_response :redirect
    assert_redirected_to :action => 'index'
  end

  def test_金融機関が未登録
    Bank.delete_all
    sign_in user
    get :index
    assert_response :success
    assert_template 'common/banks_required'
  end
end
