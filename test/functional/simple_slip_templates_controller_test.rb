# coding: UTF-8
#
# $Id: simple_slip_templates_controller_test.rb 3364 2014-02-07 09:00:18Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class SimpleSlipTemplatesControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id] = users(:first).id
  end

  def test_追加画面表示
    get :new, :format => 'js'

    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:simple_slip_template)
  end

  def test_編集画面表示
    get :edit, :id => 4, :format => 'js'

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:simple_slip_template)
  end
end
