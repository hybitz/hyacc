# coding: UTF-8
#
# $Id: withholding_slip_controller_test.rb 3355 2014-02-07 02:27:50Z ichy $
# Product: hyacc
# Copyright 2013-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class WithholdingSlipControllerTest < ActionController::TestCase

  setup do
    @request.session[:user_id] = users(:first).id
  end
  
  def test_should_get_list
    get :list
    assert_response :success
  end

end
