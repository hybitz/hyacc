# coding: UTF-8
#
# $Id: banks_controller_test.rb 3296 2014-01-24 04:00:10Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class BanksControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end
  
  def test_index
    get :index, :commit => '表示'
    assert_response :success
    assert_not_nil assigns(:banks)
  end

  def test_new
    get :new, :format => 'js'
    assert_response :success
  end

  def test_create
    assert_difference('Bank.count') do
      post :create, :format => 'js',
          :bank => {:name => '三井住友銀行',
                    :code => '0009',
                    :deleted => false}
    end

    assert_response :success
  end

  def test_show
    get :show, :format => 'js', :id => banks(:data1).to_param
    assert_response :success
  end

  def test_edit
    get :edit, :format => 'js', :id => banks(:data1).to_param
    assert_response :success
  end

  def test_update
    put :update, :format => 'js', :id => banks(:data1).to_param, :bank => { }
    assert_response :success
  end

  def test_destroy
    assert_difference('Bank.count', -1) do
      delete :destroy, :id => banks(:data1).to_param
    end

    assert_redirected_to  :action=>'index', :commit=>''
  end
end
