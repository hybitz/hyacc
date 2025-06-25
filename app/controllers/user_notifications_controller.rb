class UserNotificationsController < Base::HyaccController
  
  def index
    @n = Notification.last
    @un = UserNotification.find_by(notification_id: @n.id, user_id: current_user.id) if @n
  end

  def update
    @un = UserNotification.find(params[:id])
    begin
      @un.update!(un_params)

      flash[:notice] = 'お知らせの表示設定を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render 'index'
    end
  end

  private

  def un_params
    params.require(:user_notification).permit(:visible)
  end
end