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

  def test_update_visibility_settings_一件のレコードを更新する
    sign_in user
    un1 =  user.user_notifications
    .joins(:notification)
    .where(visible: true, notifications: {deleted: false}).first

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        un1.id => {visible: false}
      }
    }

    assert_not un1.reload.visible?
    assert_response :success
    assert_template 'common/reload'
    assert_equal 'お知らせの表示設定を更新しました。', flash[:notice]
  end

  def test_update_visibility_settings_複数のレコードを更新する
    UserNotification.delete_all
    Notification.delete_all
    ids = [2023, 2024, 2021, 2022].map do |year|
      notification = Notification.create!(message: year, deleted: false, created_at: Date.new(year, 6, 1), category: 1)
      user.user_notifications.create!(notification: notification).id
    end

    sign_in user

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        ids[0] => {visible: false},
        ids[1] => {visible: true},
        ids[2] => {visible: false},
        ids[3] => {visible: true},
      }
    }

    assert_response :success
    assert_template 'common/reload'
    assert_equal "お知らせの表示設定を更新しました。", flash[:notice]
    assert_equal [[ids[0], false], [ids[1],true], [ids[2] ,false], [ids[3], true]], UserNotification.where(id: ids).pluck(:id, :visible)
  end

  def test_update_他のユーザのお知らせを更新しようとするとエラーになる
    user2 = User.second
    sign_in user2
    un1 =  user.user_notifications
    .joins(:notification)
    .where(visible: true, notifications: {deleted: false}).first

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        un1.id => {visible: false}
      }
    }

    assert_response :success
    assert_template 'index'
    assert_equal "指定されたお知らせ（ID: #{un1.id})が見つかりませんでした。", flash[:notice]
    assert un1.visible?
  end

  def test_update_存在しないお知らせを更新しようとするとエラーになる
    sign_in user
    non_existing_id = UserNotification.maximum(:id).to_i + 1
    assert_nil UserNotification.find_by(id: non_existing_id)

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        non_existing_id => {visible: false}
      }
    }

    assert_response :success
    assert_template 'index'
    assert_equal "指定されたお知らせ（ID: #{non_existing_id})が見つかりませんでした。", flash[:notice]
  end

  def test_HyaccException発生時はエラーメッセージを併せて表示する
    sign_in user

    un = user.user_notifications
    .joins(:notification)
    .where(visible: true, notifications: {deleted: false}).first
    
    UserNotification.class_eval do
      alias_method :original_update!, :update!
    
      def update!(*args)
        raise HyaccException.new('テスト用の例外です')
      end
    end

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        un.id => {visible: false}
      }
    }

    assert_response :success
    assert_template 'index'
    assert_equal '「令和7年の算定...」の更新に失敗しました。: テスト用の例外です', flash[:notice]

    UserNotification.class_eval do
      alias_method :update!, :original_update!
      remove_method :original_update!
    end  
  end

  def test_load_users_and_user_notifications
    UserNotification.delete_all
    Notification.delete_all
    active_notification = Notification.create!(message: 2025, deleted: false, created_at: Date.new(2025, 6, 1), category: 1)
    user.user_notifications.create!(notification: active_notification)

    [2023, 2024, 2021, 2022].each do |year|
      notification = Notification.create!(message: year, deleted: true, created_at: Date.new(year, 6, 1), category: 1)
      user.user_notifications.create!(notification: notification)
    end

    sign_in user
    get :index, xhr: true

    deleted_notifications = assigns(:deleted_notifications)
    refute_includes deleted_notifications, active_notification
    assert_equal ["2024", "2023", "2022", "2021"], deleted_notifications.pluck(:message)

    user_notifications = assigns(:user_notifications)
    assert_equal active_notification, user_notifications.first.notification
  end
end
