class UserNotificationsController < Base::HyaccController
  
  def index
    load_notifications_and_user_noifications
  end

  def update
    begin
      @un = current_user.user_notifications.find(params[:id])
      @un.update!(un_params)

      flash[:notice] = 'お知らせの表示設定を更新しました。'
      render 'common/reload'
    rescue ActiveRecord::RecordNotFound => e
      flash[:notice] = '指定されたお知らせが見つかりませんでした。'
      flash[:is_error_message] = true
      load_notifications_and_user_noifications
      render 'index'
    rescue => e
      handle(e)
      load_notifications_and_user_noifications
      render 'index'
    end
  end

  private

  def load_notifications_and_user_noifications
    @n = Notification.last
    @un = UserNotification.find_by(notification_id: @n.id, user_id: current_user.id) if @n
  end

  def un_params
    params.require(:user_notification).permit(:visible)
  end
end