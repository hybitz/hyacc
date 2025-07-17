require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  def test_sync_user_notifications_with_deleted_flag
    n = Notification.where(deleted: false).first
    assert n.user_notifications.where(deleted: false).size > 0

    n.update!(deleted: true)
    assert_empty n.user_notifications.where(deleted: false)

    n.update!(deleted: false)
    assert n.user_notifications.where(deleted: false).size > 0
  end

  def test_sync_user_notifications_with_deleted_flag_紐づくuserが削除済みの場合は同期しない
    n = Notification.where(deleted: false).first
    user2 = User.where(deleted: false).second
    un2 = UserNotification.create!(notification: n, user: user2)

    user3 = User.where(deleted: false).find(3)
    un3 = UserNotification.create!(notification: n, user: user3)

    n.update!(deleted: true)
    assert un2.reload.deleted?
    assert un3.reload.deleted?

    user2.update!(deleted: true)
    n.update!(deleted: false)
    assert un2.reload.deleted?
    assert_not un3.reload.deleted?
  end

end