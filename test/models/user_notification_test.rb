require 'test_helper'

class UserNotificationTest < ActiveSupport::TestCase
  def test_ユーザとお知らせの紐づけは重複して行えない
    user = User.first
    notification = Notification.first
    assert UserNotification.find_by(user: user, notification: notification).present?
    un = UserNotification.new(user: user, notification: notification)
    assert_not un.valid?
    assert_equal ["ユーザとお知らせの紐づけは重複して行えません。"], un.errors[:notification_id]
  end

end