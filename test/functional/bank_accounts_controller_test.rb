# coding: UTF-8
#
# Product: hyacc
# Copyright 2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class BankAccountsControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index
    assert_response :success
    assert_template :index
  end

  def test_追加
    sign_in user
    get :new, :format => 'js'
    assert_response :success
    assert_template :new
  end
  
  def test_登録
    sign_in user
    post :create, :format => 'js', :bank_account => valid_bank_account_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_登録_入力エラー
    sign_in user
    post :create, :format => 'js', :bank_account => invalid_bank_account_params
    assert_response :success
    assert_template :new
  end
  
  def test_編集
    sign_in user
    get :edit, :format => 'js', :id => bank_account.id
    assert_response :success
    assert_template :edit
  end
  
  def test_更新
    sign_in user
    put :update, :format => 'js', :id => bank_account.id, :bank_account => valid_bank_account_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    put :update, :format => 'js', :id => bank_account.id, :bank_account => invalid_bank_account_params
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
