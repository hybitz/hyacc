require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest

  def test_初期状態
    assert UserNotification.delete_all
    assert User.delete_all

    get root_path
    assert_response :redirect
    follow_redirect!
    assert_equal '/first_boot', path
  end

  def test_get_notificationでStandardErrorが発生する場合
    user = User.first
    sign_in user
 
    NotificationService.singleton_class.class_eval do
      alias_method :original_get_notification, :get_notification
      define_method(:get_notification) do |*_args|
        raise StandardError
      end
    end
  
    assert_raises StandardError do
      get root_path
    end

  ensure
    NotificationService.singleton_class.class_eval do
      alias_method :get_notification, :original_get_notification
      remove_method :original_get_notification 
    end
  end

  def test_get_notificationでRecordInvalidが発生する場合
    user = User.first
    sign_in user
 
    NotificationService.singleton_class.class_eval do
      alias_method :original_get_notification, :get_notification
      define_method(:get_notification) do |*_args|
        raise ActiveRecord::RecordInvalid.new(UserNotification.new)
      rescue ActiveRecord::RecordInvalid => e
        raise HyaccException.new("ユーザとお知らせの紐づけに失敗しました: #{e.message}")
      end
    end

    get root_path
  
    assert_match "ユーザとお知らせの紐づけに失敗しました", flash[:notice]
  
  ensure
    NotificationService.singleton_class.class_eval do
      alias_method :get_notification, :original_get_notification
      remove_method :original_get_notification    
    end
  end

end
