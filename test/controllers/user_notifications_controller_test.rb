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
    Notification.last.destroy
    sign_in user
    get :index, xhr: true
    assert_response :success
    assert_nil assigns(:n)
    assert_nil assigns(:un)
  end

  def test_update
    sign_in user
    @un = UserNotification.first
    assert @un.visible?
    patch :update, xhr: true, params: {id: @un.id, user_notification: {visible: false}}
    un = assigns(:un)
    assert_not un.visible?
    assert_response :success
    assert_equal 'お知らせの表示設定を更新しました。', flash[:notice]
  end

  def test_update_エラー
    sign_in user
    un_1 = UserNotification.first
    assert un_1.visible?
    patch :update, xhr: true, params: {id: 2, user_notification: {visible: false}}
    assert_response :success
    assert_equal "指定されたお知らせが見つかりませんでした。", flash[:notice]
    un_1.reload
    assert un_1.visible?
  end
end
