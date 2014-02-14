# coding: UTF-8
#
# $Id: bank_offices_controller_test.rb 3165 2014-01-01 11:37:37Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class BankOfficesControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end
  
  def test_一覧
    get :index
    assert_response :success
    assert_not_nil assigns(:bank_offices)
  end

  def test_追加
    get :new
    assert_response :success
  end

  def test_登録
    assert_difference('BankOffice.count') do
      post :create,
          :bank_office => {
            :bank_id => '3',
            :name => '本店',
            :code => '001',
            :deleted => false
          }
    end

    assert_redirected_to bank_office_path(assigns(:bank_office))
  end

  test "should show bank_office" do
    get :show, :id => bank_offices(:data1).to_param
    assert_response :success
  end

  def test_編集
    get :edit, :id => bank_offices(:data1).to_param
    assert_response :success
  end

  def test_更新
    put :update, :id => bank_offices(:data1).to_param, :bank_office => { }
    assert_redirected_to bank_office_path(assigns(:bank_office))
  end

  def test_削除
    assert_difference('BankOffice.count', -1) do
      delete :destroy, :id => bank_offices(:data1).to_param
    end

    assert_redirected_to bank_offices_path
  end

end
