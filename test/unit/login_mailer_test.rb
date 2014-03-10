# -*- encoding : utf-8 -*-
#
# $Id: login_notice_test.rb 2681 2011-09-16 08:50:24Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class LoginMailerTest < ActionMailer::TestCase
  def test_invoice_login
    params = {:time=>'20110916', :who=>User.new}
    
    email = LoginMailer.invoice_login("admin@hybitz.co.jp", params).deliver
    assert_equal ['info@hybitz.co.jp'], email.from
  end
end
