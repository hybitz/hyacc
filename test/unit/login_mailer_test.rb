# -*- encoding : utf-8 -*-
require 'test_helper'

class LoginMailerTest < ActionMailer::TestCase
  def test_invoice_login
    params = {:time=>'20110916', :who=>User.new}
    
    email = LoginMailer.invoice_login("admin@hybitz.co.jp", params).deliver
    assert_equal ['info@hybitz.co.jp'], email.from
  end
end
