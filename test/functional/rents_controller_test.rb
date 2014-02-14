# coding: UTF-8
#
# $Id: rents_controller_test.rb 3355 2014-02-07 02:27:50Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class RentsControllerTest < ActionController::TestCase

  def setup
    # ログインした状態を再現
    @request.session[:user_id] = users(:first).id
    @request.session[:company] = companies(:a)
  end
  
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:rents)
  end

  def test_should_get_new
    get :new
    assert_response :success
    assert_not_nil assigns(:rent)
  end

  def test_should_create_rent
    assert_difference('Rent.count') do
      post :create, :rent => {:rent_type => "1", :usage_type => "1",
                              :address => "住所", :customer_id => "1",
                              :name => "表示名",
                              :status => "1", :ymd_start => "20071010" }
    end

    assert_response :success
  end
  
  def test_should_create_rent_with_errors
    post :create, :rent => {:rent_type => "", :usage_type => "",
                            :address => "住所", :customer_id => "1",
                            :name => "",
                            :status => "", :ymd_start => "", :ymd_end => "2009010" }
    
    assert_response :success
    assert_equal 6, assigns(:rent).errors.size
    assert_template 'new'
  end
  
  def test_should_get_edit
    get :edit, :id => rents(:rent_00005).id
    assert_response :success
  end

  def test_should_update_rent
    put :update, :id => rents(:rent_00005).id,
                              :rent => {:rent_type => "1", :usage_type => "1",
                                        :address => "住所", :customer_id => "1",
                                        :name => "表示名",
                                        :status => "0" }
    assert_response :success
  end

  def test_should_destroy_rent
    assert_difference('Rent.count', -1) do
      delete :destroy, :id => rents(:rent_00005).id
    end

    assert_redirected_to rents_path
  end
end
