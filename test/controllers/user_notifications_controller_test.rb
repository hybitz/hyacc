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
end
