class UserNotificationsController < Base::HyaccController
  
  def index
    load_notifications_and_user_noifications
  end

  def update_visibility_settings
    errors = []
    params[:user_notifications]&.each do |id, u|
      un = current_user.user_notifications
        .joins(:notification)
        .where(notifications: {deleted: false})
        .find_by(id: id)

      if un.nil?
        errors << "指定されたお知らせ（ID: #{id})が見つかりませんでした。"
        next
      end

      begin
        new_visible = ActiveRecord::Type::Boolean.new.cast(u[:visible])
        if un.visible != new_visible
          un.update!(visible: new_visible)
        end
    
      rescue => e
        message = "#{un.notification.message.truncate(10)}"
        handle(e)
        flash[:notice] = flash[:notice].presence || '予期せぬエラーが発生しました。'
        errors << "「#{message}」の更新に失敗しました。: #{flash[:notice]}"
      end
    end

    if errors.any?
      flash[:notice] = errors.join("<br/>")
      flash[:is_error_message] = true
      load_notifications_and_user_noifications
      render 'index'
    else
      flash[:notice] = 'お知らせの表示設定を更新しました。'
      render 'common/reload'
    end
  end

  private

  def load_notifications_and_user_noifications
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
end