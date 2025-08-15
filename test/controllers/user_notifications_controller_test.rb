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

  def test_一件のレコードを更新する
    sign_in user
    un =  user.user_notifications
    .joins(:notification)
    .where(visible: true, notifications: {deleted: false}).first

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        un.id => {visible: false}
      }
    }

    assert_response :success
    assert_template 'common/reload'
    assert_equal @response.media_type, 'text/javascript'
    assert_equal 'お知らせの表示設定を更新しました。', flash[:notice]
    assert_not un.reload.visible?
  end

  def test_複数のレコードを更新する
    UserNotification.delete_all
    Notification.delete_all
    ids = [2023, 2024, 2021, 2022].map do |year|
      notification = Notification.create!(message: year, deleted: false, created_at: Date.new(year, 6, 1), category: :report_submission)
      user.user_notifications.create!(notification: notification).id
    end

    sign_in user

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        ids[0] => {visible: false},
        ids[1] => {visible: true},
        ids[2] => {visible: false},
        ids[3] => {visible: true}
      }
    }

    assert_response :success
    assert_template 'common/reload'
    assert_equal @response.media_type, 'text/javascript'
    assert_equal "お知らせの表示設定を更新しました。", flash[:notice]
    assert_equal [[ids[0], false], [ids[1],true], [ids[2] ,false], [ids[3], true]], UserNotification.where(id: ids).pluck(:id, :visible)
  end

  def test_他のユーザのお知らせを更新しようとするとエラーになる
    user2 = User.second
    sign_in user2

    un =  user.user_notifications
    .joins(:notification)
    .where(visible: true, notifications: {deleted: false}).first

    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        un.id => {visible: false}
      }
    }

    assert_response :success
    assert_template 'index'
    assert_equal @response.media_type, 'text/javascript'
    assert_equal "1件の更新失敗：削除済みまたは更新対象外のため", flash[:notice]
    assert un.reload.visible?
  end

  def test_更新時のループ処理は例外が発生しても継続する
    sign_in user
    n = Notification.create!(deleted: false, category: :ad_hoc_revision)
    user.user_notifications.create!(notification: n)

    fail_un, ok_un =  user.user_notifications
    .joins(:notification)
    .where(visible: true, notifications: {deleted: false}).limit(2).to_a
    fail_un_id = fail_un.id
    ok_un_id   = ok_un.id

    ids = []
    base_id = UserNotification.maximum(:id).to_i

    3.times do |i|
      id = base_id + i + 1
      assert_nil UserNotification.find_by(id: id)
      ids << id
    end

    non_existing_id1, non_existing_id2, non_existing_id3 = ids
    missing_count = ids.size

    UserNotification.class_eval do
      alias_method :original_update!, :update!
    
      define_method :update! do |*args|
        if self.id == fail_un_id
          raise ActiveRecord::StaleObjectError
        else
          original_update!(*args)
        end
      end
    end
    
    patch :update_visibility_settings, xhr: true, params: {
      user_notifications: {
        non_existing_id1 => {visible: false},
        fail_un_id => {visible: false},
        non_existing_id2 => {visible: false},
        ok_un_id => {visible: false},
        non_existing_id3 => {visible: false}
      }
    }

    assert_response :success
    assert_template 'index'
    assert_equal @response.media_type, 'text/javascript'
    assert_equal "「令和7年の算定...」の更新失敗：古いデータを更新しようとしました。<br/>その他#{missing_count}件の更新失敗：削除済みまたは更新対象外のため", flash[:notice] 
    
    assert fail_un.reload.visible?
    assert_not ok_un.reload.visible?

    UserNotification.class_eval do
      alias_method :update!, :original_update!
      remove_method :original_update!
    end 
  end

  def test_load_users_and_user_notifications
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
end
