require "test_helper"

class UserNotificationsControllerTest < ActionController::TestCase
  def test_index_notificationレコードがある場合
    sign_in user
    get :index, xhr: true
    assert_response :success
    assert_not_nil assigns(:n)
    assert_not_nil assigns(:un)
  end

  def test_index_notificationレコードが無い場合
    Notification.delete_all
    sign_in user
    get :index, xhr: true
    assert_response :success
    assert_nil assigns(:n)
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
end
