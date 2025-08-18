require "test_helper"

class UserNotificationsControllerTest < ActionController::TestCase
  def test_index_有効なnotificationレコードがある場合
    assert_not_empty Notification.where(deleted: false)
    assert_empty Notification.where(deleted: true)

    sign_in user
    get :index, xhr: true
    assert_response :success

    assert_not_empty assigns(:user_notifications)
    assert_empty assigns(:deleted_notifications)
  end

  def test_index_有効なnotificationレコードが無い場合
    Notification.update_all(deleted: true)

    sign_in user
    get :index, xhr: true
    assert_response :success

    assert_empty assigns(:user_notifications)
    assert_not_empty assigns(:deleted_notifications)
  end

  def test_レコードはcreated_atの降順で表示する
    UserNotification.delete_all
    Notification.delete_all

    [2023, 2024, 2021, 2022].each do |year|
      notification = Notification.create!(
        message: year, 
        deleted: false, 
        created_at: Date.new(year, 6, 1),
        category: :report_submission)
      user.user_notifications.create!(notification: notification)
    end

    [2023, 2024, 2021, 2022].each do |year|
      notification = Notification.create!(
        message: year, 
        deleted: true, 
        created_at: Date.new(year, 6, 1),
        category: :report_submission)
      user.user_notifications.create!(notification: notification)
    end

    sign_in user
    get :index, xhr: true

    deleted_notifications = assigns(:deleted_notifications)
    active_notifications = Notification.where(deleted: false)
    assert_not_includes deleted_notifications, active_notifications
    assert_equal ["2024", "2023", "2022", "2021"], deleted_notifications.pluck(:message)

    user_notifications = assigns(:user_notifications)
    assert_equal ["2024", "2023", "2022", "2021"], user_notifications.map {|un| un.notification.message}
  end

  def test_更新
    sign_in user

    user_notification = UserNotification.first
    
    assert_changes 'user_notification.reload.visible' do
      patch :update, xhr: true, params: {id: user_notification.id,
        user_notification: {visible: false}
      }
    end

    assert_response :success
    assert_not user_notification.reload.visible?
  end

  def test_更新_エラー
    sign_in user

    user_notification = UserNotification.first
    user_notification.notification.update!(deleted: true)

    assert_no_changes 'user_notification.reload.visible' do
      patch :update, xhr: true, params: {id: user_notification.id,
      user_notification: {visible: false}
      }
    end

    assert_response :unprocessable_entity
  end

end
