require 'test_helper'

class LoginMailerTest < ActionMailer::TestCase

  def test_invoice_login
    email = LoginMailer.invoice_login(user).deliver_now
    assert_equal ['info@hybitz.co.jp'], email.from
  end
end
