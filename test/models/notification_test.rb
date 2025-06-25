require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  def test_formatted_message
    n = Notification.first
    assert_equal "令和7年の算定基礎届の提出期限は <span style='color: red;'>7月10日</span> です。", n.formatted_message
  end

  def test_dependent_destroy
    n = Notification.first
    assert n.user_notifications.size > 0
    n.destroy
    assert n.user_notifications.size == 0
  end
end