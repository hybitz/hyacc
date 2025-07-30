require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  def test_category_required
    notification = Notification.new(message: "テスト", category: :report_submission)
    assert_nothing_raised{ notification.save! }

    notification = Notification.new(message: "テスト", category: nil)
    assert_raise( ActiveRecord::RecordInvalid ){ notification.save! }
  end

  def test_with_active_or_no_employee
    active_employee = Employee.where(deleted: false).first
    deleted_employee = Employee.where(deleted: false).second
    deleted_employee.update!(deleted: true)
    notification1 = Notification.create!(message: "テスト", category: :report_submission, employee: nil)
    notification2 = Notification.create!(message: "テスト", category: :annual_determination, employee: active_employee)
    notification3 = Notification.create!(message: "テスト", category: :ad_hoc_revision, employee: deleted_employee)
    
    notifications = Notification.with_active_or_no_employee
    assert_includes notifications, notification1
    assert_includes notifications, notification2
    refute_includes notifications, notification3
  end

  def test_visible_to_user
    notification = Notification.create!(message: "テスト", category: :report_submission, deleted: false)
    hidden_notification = Notification.create!(message: "テスト", category: :annual_determination, deleted: false)
    deleted_notification = Notification.create!(message: "テスト", category: :ad_hoc_revision, deleted: true)
  
    UserNotification.create!(user: user, notification: notification, visible: true)
    UserNotification.create!(user: user, notification: hidden_notification, visible: false)
    UserNotification.create!(user: user, notification: deleted_notification, visible: true)

    notifications = Notification.visible_to_user(user)
    assert_includes notifications, notification
    refute_includes notifications, hidden_notification
    refute_includes notifications, deleted_notification
  end

end