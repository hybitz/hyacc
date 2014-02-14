# coding: UTF-8
#
# $Id: login_helper_test.rb 3102 2013-07-24 14:47:54Z ichy $
# Product: hyacc
# Copyright 2009-2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class LoginHelperTest < ActionView::TestCase
  include LoginHelper
  
  def test_get_alert_mail_to
    assert_equal 'admin@test.com', get_alert_mail_to(nil)
    assert_equal 'user1@example.com', get_alert_mail_to(User.find(1))
  end
end
