module PayrollNotification
  class ReportSubmissionNoticeGenerator
     def self.call
      new.execute
    end

    def execute
      @message = build_message
      notification = Notification.find_by(message: @message)
      return if notification
      create_notification_and_user_notifications
    end

    private

    def build_message
      due_date = Date.new(Date.current.year, 7, 10)
      due_date += 1 while !HyaccDateUtil.weekday?(due_date)
      message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"
      message
    end

    def create_notification_and_user_notifications
      begin
        notification = Notification.create!(category: :report_submission, message: @message)
        HyaccLogger.info("お知らせ生成成功: message=#{@message}")
      rescue => e
        HyaccLogger.error("お知らせ生成失敗: error=#{e.message}")
        return
      end

      failures = []
      User.where(deleted: false).find_each do |user|
        begin
          UserNotification.find_or_create_by!(user_id: user.id, notification_id: notification.id)
          HyaccLogger.info("お知らせ紐づけ成功: notification_id=#{notification.id}, user_id=#{user.id}")
        rescue => e
          failures << "user_id=#{user.id} error=#{e.message}"
        end
      end

      if failures.any?
        HyaccLogger.error("紐づけ失敗: #{failures.join("\n")}")
      end
    end
  end
end