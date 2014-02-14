# coding: UTF-8
#
# $Id: inhabitant_taxes_controller_test.rb 3355 2014-02-07 02:27:50Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class InhabitantTaxesControllerTest < ActionController::TestCase

  setup do
    @request.session[:user_id] = users(:first).id
  end

  def test_一覧
    get :index, :commit=>'表示', :finder=>{:year=>'2009'}
    assert_response :success
    assert_not_nil assigns(:list)
  end

  def test_upload_success
    post :upload,:file => upload_file('inhabitant_tax.csv')
    assert_redirected_to :action => "index"
    assert_equal 48,assigns(:list).size
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inhabitant_tax" do
    assert_difference('InhabitantTax.count') do
      post :create, :inhabitant_tax => {:ym=>200901, :employee_id=>2, :amount=>0}
    end

  end

  test "should show inhabitant_tax" do
    get :show, :id => InhabitantTax.find(:first)
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => InhabitantTax.find(:first)
    assert_response :success
  end

  test "should update inhabitant_tax" do
    put :update, :id => InhabitantTax.find(:first).id.to_i,
        :inhabitant_tax => { :employee_id=>2,:amount=>10000}
    assert_response :success
    assert_template 'line'
  end

  test "should destroy inhabitant_tax" do
    assert_difference('InhabitantTax.count', -1) do
      delete :destroy, :id => InhabitantTax.find(:first).id.to_i
    end
    assert_redirected_to :action=>'index', :commit=>''
  end
  
end
