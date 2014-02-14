# coding: UTF-8
#
# $Id: company_controller_test.rb 3165 2014-01-01 11:37:37Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class CompanyControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template :index
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:capital)
  end
end
