module RetirementSavingsNotification
  class StartNoticeCleaner
    def self.call
      new.execute
    end

    def execute
      target_period = Time.current.prev_month(2).beginning_of_month...Time.current.prev_month(1).beginning_of_month
      scope = Notification.where(category: :retirement_savings, deleted: false).where(created_at: target_period)

      scope.find_each do |notification|
        begin
          notification.update!(deleted: true)
          HyaccLogger.info("退職金積立開始のお知らせ削除成功：notification_id=#{notification.id}")
        rescue => e
          HyaccLogger.error("退職金積立開始のお知らせ削除失敗：notification_id=#{notification.id}, error=#{e.message}")
        end
      end
    end
  end
end