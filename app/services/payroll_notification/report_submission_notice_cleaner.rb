module PayrollNotification
  class ReportSubmissionNoticeCleaner
    def self.call
      new.execute
    end

    def execute
      target_period = Time.current.change(month: 6).beginning_of_month..Time.current.change(month: 6).end_of_month
      @notification = Notification.find_by(created_at: target_period, category: :report_submission)
      return if @notification.nil? || @notification.deleted?
      cleanup_existing_notification
    end

    private

    def cleanup_existing_notification
      begin
        @notification.update!(deleted: true)
        HyaccLogger.info("お知らせ削除成功: notification_id=#{@notification.id}")
      rescue => e
        HyaccLogger.error("お知らせ削除失敗: error=#{e.message}")
      end
    end
  end
end