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

  def test_sync_visibility_with_deleted_flag_紐づくnotificationを削除した場合
    n = Notification.where(deleted: false).first
    assert n.user_notifications.where(visible: true).size > 0
    n.update!(deleted: true)
    assert_empty n.user_notifications.where(visible: true)
  end

  def test_sync_visibility_with_deleted_flag_紐づくuserを削除した場合
    assert user.user_notifications.where(visible: true).size > 0
    user.update!(deleted: true)
    assert_empty user.user_notifications.where(visible: true)
  end
end