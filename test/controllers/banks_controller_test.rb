require 'test_helper'

class BanksControllerTest < ActionController::TestCase

  def test_一覧
    sign_in user
    get :index, :commit => '表示'
    assert_response :success
    assert_not_nil assigns(:banks)
  end

  def test_追加
    sign_in user
    xhr :get, :new
    assert_response :success
    assert_template :new
  end

  def test_登録
    sign_in user

    assert_difference('Bank.count') do
      xhr :post, :create, :bank => valid_bank_params
      assert_response :success
      assert_template 'common/reload'
    end
  end

  def test_登録_入力エラー
    sign_in user

    assert_no_difference('Bank.count') do
      xhr :post, :create, :bank => invalid_bank_params
      assert_response :success
      assert_template 'new'
    end
  end

  def test_参照
    sign_in user
    xhr :get, :show, :id => banks(:data1).id
    assert_response :success
  end

  def test_編集
    sign_in user
    xhr :get, :edit, :id => bank.id
    assert_response :success
    assert_template :edit
  end

  def test_更新
    sign_in user
    xhr :patch, :update, :id => bank.id, :bank => valid_bank_params
    assert_response :success
    assert_template 'common/reload'
  end

  def test_更新_入力エラー
    sign_in user
    xhr :patch, :update, :id => bank.id, :bank => invalid_bank_params
    assert_response :success
    assert_template 'edit'
  end

  def test_削除
    sign_in user

    assert_no_difference 'Bank.count' do
      delete :destroy, :id => banks(:data1).id
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end
  end

  def test_営業店舗追加
    sign_in user
    xhr :get, :add_bank_office
    assert_response :success
    assert_template 'banks/_bank_office_fields'
  end

end
