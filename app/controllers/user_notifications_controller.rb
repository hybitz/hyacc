class UserNotificationsController < Base::HyaccController
  
  def index
    @deleted_notifications = Notification
      .joins(:user_notifications)
      .where(deleted: true, user_notifications: {user_id: current_user.id})
      .order(created_at: :desc)
    @user_notifications = UserNotification
      .joins(:notification)
      .where(notifications: {deleted: false}, user_id: current_user.id)
      .includes(:notification)
      .order('notifications.created_at DESC')
  end

  def update
    un = current_user.user_notifications
      .joins(:notification)
      .where(notifications: {deleted: false})
      .find_by(id: params[:id])

    return head :unprocessable_content if un.nil?

    if un.update(user_notification_params)
      render json: { message: 'ok' }
    else
      head :unprocessable_content
    end
  end

  private

  def user_notification_params
    params.require(:user_notification).permit(:visible)
  end
end