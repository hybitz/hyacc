class UserNotificationsController < Base::HyaccController
  
  def index
    load_notifications_and_user_notifications
  end

  def update_visibility_settings
    errors = []
    missing_count = 0

    un_params.each do |id, attrs|
      un = find_user_notification(id)

      if un.nil?
        missing_count += 1
        next
      end

      visible = attrs[:visible]
      next if un.visible == visible

      begin
        un.update!(visible: visible)
      rescue => e
        handle(e)
        err_msg = flash[:notice].presence || '予期せぬエラーが発生しました。'
        errors << build_update_error_message(un, err_msg)
      end
    end

    errors << build_missing_count_message(missing_count, errors.any?) if missing_count > 0
  
    if errors.any?
      flash[:notice] = errors.join("<br/>")
      flash[:is_error_message] = true
      load_notifications_and_user_notifications
      render 'index'
    else
      flash[:notice] = 'お知らせの表示設定を更新しました。'
      render 'common/reload'
    end
  end

  private

  def load_notifications_and_user_notifications
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

  def un_params
    raw = params.require(:user_notifications)
    ids = raw.keys
    permitted = raw.permit(ids.index_with {[:visible]}).to_h
    permitted.transform_values do |attrs|
      { visible: ActiveModel::Type::Boolean.new.cast(attrs[:visible]) }
    end
  end

  def find_user_notification(id)
    current_user.user_notifications
      .joins(:notification)
      .where(notifications: {deleted: false})
      .find_by(id: id)
  end

  def build_update_error_message(un, err_msg)
    title = un.notification.message.truncate(10)
    "「#{title}」の更新失敗：#{err_msg}"
  end

  def build_missing_count_message(count, has_other_errors)
    prefix = has_other_errors ? "その他" : ""
    "#{prefix}#{count}件の更新失敗：削除済みまたは更新対象外のため"
  end
end