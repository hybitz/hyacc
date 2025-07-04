require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  def test_dependent_destroy
    n = Notification.first
    assert n.user_notifications.size > 0
    n.destroy
    assert n.user_notifications.size == 0
  end
end