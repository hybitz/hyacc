# coding: UTF-8

require 'test_helper'

class LoginHelperTest < ActionView::TestCase
  
  def test_get_alert_mail_to
    assert_equal 'admin@test.com', get_alert_mail_to(nil)
    assert_equal 'user1@example.com', get_alert_mail_to(User.first)
  end

end
