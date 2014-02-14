# coding: UTF-8
#
# $Id: login_controller_test.rb 3165 2014-01-01 11:37:37Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  
  def test_login
    post :login, :user => {:login_id => users(:first).login_id,
                           :password => users(:first).password}
    assert_response :redirect
    assert_redirected_to :controller => 'notification', :action => 'index'
  end
end
