require "test_helper"

class UserNotificationsControllerTest < ActionController::TestCase
  def test_index_有効なnotificationレコードがある場合
    assert_not_empty Notification.where(deleted: false)
    assert_empty Notification.where(deleted: true)

    sign_in user
    get :index, xhr: true
    assert_response :success
    assert_empty assigns(:n_deleted)
    assert_not_nil assigns(:n_active)
  end

  def test_index_有効なnotificationレコードが無い場合
    Notification.first.update!(deleted: true)
    assert_empty Notification.where(deleted: false)

    sign_in user
    get :index, xhr: true
    assert_response :success
    assert_not_empty assigns(:n_deleted)
    assert_nil assigns(:n_active)
    assert_nil assigns(:un)
  end

  def test_update
    sign_in user
    un = UserNotification.first
    assert_equal user, un.user
    assert un.visible?
    patch :update, xhr: true, params: {id: un.id, user_notification: {visible: false}}
    un = assigns(:un)
    assert_not un.visible?
    assert_response :success
    assert_template 'common/reload'
    assert_equal 'お知らせの表示設定を更新しました。', flash[:notice]
  end

  def test_update_他のユーザのお知らせを更新しようとするとエラーになる
    user2 = User.second
    sign_in user2
    un = UserNotification.first
    refute_equal user2, un.user
    assert un.visible?

    patch :update, xhr: true, params: {id: un.id, user_notification: {visible: false}}

    assert_response :success
    assert_template 'index'
    assert_equal "指定されたお知らせが見つかりませんでした。", flash[:notice]
    un.reload
    assert un.visible?
  end

  def test_update_存在しないお知らせを更新しようとするとエラーになる
    sign_in user
    non_existing_id = UserNotification.maximum(:id).to_i + 1
    assert_nil UserNotification.find_by(id: non_existing_id)

    patch :update, xhr: true, params: {id: non_existing_id, user_notification: {visible: false}}

    assert_response :success
    assert_template 'index'
    assert_equal '指定されたお知らせが見つかりませんでした。', flash[:notice]
  end

  def test_load_users_and_user_notifications
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
    n_deleted = assigns(:n_deleted)
    n_active = assigns(:n_active)
    assert_not_nil n_active

    refute_includes n_deleted, n_active
    assert_equal ["2024", "2023", "2022", "2021"], n_deleted.pluck(:message)
  end
end
