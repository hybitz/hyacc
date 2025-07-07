require 'test_helper'
require 'date'

class NotificationServiceTest < ActiveSupport::TestCase
  def test_get_notification_5月ログイン時にレコードがある場合
    date = Date.new(2025, 5, 31)
    notification = nil
    assert_difference('Notification.count', -1)  do
      assert_difference('UserNotification.count', -1) do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert_nil notification
    assert_not UserNotification.exists?
    assert_not Notification.exists?
  end

  def test_get_notification_6月と8月ログイン時にレコードがある場合
    date = Date.new(2025, 6, 1)
    notification = nil
    assert_no_difference('Notification.count') do
      assert_no_difference('UserNotification.count') do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert notification.present?

    date = Date.new(2025, 8, 31)
    notification = nil
    assert_no_difference('Notification.count') do
      assert_no_difference('UserNotification.count') do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert notification.present?
  end

  def test_get_notification_9月ログイン時にレコードがある場合
    date = Date.new(2025, 9, 1)
    notification = nil
    assert_difference('Notification.count', -1)  do
      assert_difference('UserNotification.count', -1) do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert_nil notification
    assert_not UserNotification.exists?
    assert_not Notification.exists?
  end

  def test_get_notification_5月ログイン時にレコードがない場合
    Notification.destroy_all
    date = Date.new(2025, 5, 31)
    notification = nil
    assert_no_difference('Notification.count') do
      assert_no_difference('UserNotification.count') do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert_nil notification
  end

  def test_get_notification_6月ログイン時にレコードがない場合
    Notification.destroy_all
    date = Date.new(2025, 6, 1)
    notification = nil
    assert_difference('Notification.count', 1) do
      assert_difference('UserNotification.count', 1) do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert_equal '令和7年の算定基礎届の提出期限は 7月10日 です。', notification.message
  end

  def test_get_notification_8月ログイン時にレコードがない場合
    Notification.destroy_all
    date = Date.new(2025, 8, 31)
    notification = nil
    assert_difference('Notification.count', 1) do
      assert_difference('UserNotification.count', 1) do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert_equal '令和7年の算定基礎届の提出期限は 7月10日 です。', notification.message
  end

  def test_get_notification_9月ログイン時にレコードがない場合
    Notification.delete_all
    date = Date.new(2025, 9, 1)
    notification = nil
    assert_no_difference('Notification.count') do
      assert_no_difference('UserNotification.count') do
        notification = NotificationService.get_notification(date, User.first)
      end
    end
    assert_nil notification
  end

  def test_get_notification_6月ログイン時にレコードがあるがユーザと紐づいていない場合
    date = Date.new(2025, 6, 1)
    notification = nil
    user2 = User.second
    assert_no_difference('Notification.count') do
      assert_difference('UserNotification.count', 1) do
        notification = NotificationService.get_notification(date, user2)
      end
    end
    assert notification.user_notifications.where(user_id: user2.id).present?
  end

  def test_get_notification_9月ログイン時にレコードがあるがユーザと紐づいていない場合
    date = Date.new(2025, 9, 1)
    notification = nil
    user2 = User.second
    assert_difference('Notification.count', -1) do
      assert_difference('UserNotification.count', -1) do
        notification = NotificationService.get_notification(date, user2)
      end
    end
    assert_nil notification
    assert_not UserNotification.exists?
    assert_not Notification.exists?
  end

  def test_get_due_date
    date = Date.new(2025, 6, 1)
    due_date = NotificationService.get_due_date(date)
    assert_equal '7月10日', due_date
    
    # 7月10日が土曜
    date = Date.new(2021, 6, 1)
    due_date = NotificationService.get_due_date(date)
    assert_equal '7月12日', due_date

    # 7月10日が日曜
    date = Date.new(2022, 6, 1)
    due_date = NotificationService.get_due_date(date)
    assert_equal '7月11日', due_date
  end

  def test_to_wareki_year
    date = Date.new(2025, 6, 1)
    wareki_year = NotificationService.to_wareki_year(date.year)
    assert_equal '令和7', wareki_year
  end

  def test_RecordInvalidはHyaccExceptionに変換される
    Notification.destroy_all
    user = User.first
    date = Date.new(2025,7,1)

    user.define_singleton_method(:user_notifications) do
      FakeAssociation1.new
    end
    
    error = assert_raises HyaccException do
      NotificationService.get_notification(date, user)
    end
    
    assert_match "ユーザとお知らせの紐づけに失敗しました", error.message

  ensure
    user.singleton_class.class_eval do
      remove_method :user_notifications
    end
  end

  def test_StandardErrorはHyaccExceptionに変換されない
    Notification.destroy_all
    user = User.first
    date = Date.new(2025,7,1)

    user.define_singleton_method(:user_notifications) do
      FakeAssociation2.new
    end
    
    assert_raises StandardError do
      NotificationService.get_notification(date, user)
    end

  ensure
    user.singleton_class.class_eval do
      remove_method :user_notifications
    end    
  end

  def test_RecordNotDestroyedはHyaccExceptionに変換される
    user = User.first
    date = Date.new(2025, 9, 1)
  
    fake_notification = Notification.new
    def fake_notification.destroy!(**)
      raise ActiveRecord::RecordNotDestroyed.new("削除できませんでした")
    end
  
    Notification.singleton_class.class_eval do
      alias_method :original_last, :last
      define_method(:last) {fake_notification}
    end
  
    error = assert_raises HyaccException do
      NotificationService.get_notification(date, user)
    end
  
    assert_match "お知らせの削除に失敗しました", error.message
    assert_match "削除できませんでした", error.message
  
  ensure
    Notification.singleton_class.class_eval do
      alias_method :last, :original_last
      remove_method :original_last
    end
  end
  
  class FakeAssociation1
    def create!(**)
      raise ActiveRecord::RecordInvalid.new(UserNotification.new)
    end
  end

  class FakeAssociation2
    def create!(**)
      raise StandardError
    end
  end

end