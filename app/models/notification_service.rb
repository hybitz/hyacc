class NotificationService
  def self.get_notification(date, user)
    ret = nil
    notification = Notification.last
    due_date = get_due_date(date)
    if 6 <= date.month && date.month <= 8
      if notification
        un = UserNotification.find_by(notification_id: notification.id, user_id: user.id)
        if un.nil?
          begin
            un = user.user_notifications.create!(notification: notification)
          rescue ActiveRecord::RecordInvalid => e
            raise HyaccException.new("ユーザとお知らせの紐づけに失敗しました：#{e.message}")
          end
        end
        ret = notification if un.visible?
      else  
        message = "#{to_wareki_year(date.year)}年の算定基礎届の提出期限は #{due_date} です。"
        begin
          ActiveRecord::Base.transaction do
            notification = Notification.create!(message: message)
            user.user_notifications.create!(notification: notification)
          end
        rescue ActiveRecord::RecordInvalid => e
          raise HyaccException.new("ユーザとお知らせの紐づけに失敗しました：#{e.message}")
        end
        ret = notification
      end
    else
      begin
        notification.destroy! if notification
      rescue ActiveRecord::RecordNotDestroyed => e
        raise HyaccException.new("お知らせの削除に失敗しました: #{e.message}")
      end
    end
    ret
  end

  def self.get_due_date(date)
    ret = Date.new(date.year, 7, 10)
    while !HyaccDateUtil.weekday?(ret)
      ret = ret + 1
    end
    ret.strftime("%-m月%d日")
  end

  def self.to_wareki_year(year)
    TaxJp::Gengou.to_wareki(Date.new(year.to_i, 12, 31), only_date: false, format: '%y')
  end
end