module RetirementSavingsNotification
  class StartNoticeGenerator
    def self.call
      new.execute
    end

    def execute
      scope = target_employees
      scope.find_each do |employee|
        next unless notice_due?(employee)
        begin 
        create_notification_and_user_notifications(employee)
        rescue => e
          notification_info = @notification ? "notification_id=#{@notification.id}" : "notification=なし"
          HyaccLogger.error("退職金積立開始のお知らせ生成失敗：#{notification_info}, employee_id=#{employee.id}, error=#{e.message}")
        end
      end
    end

    private

    def target_employees
      base_date = (Date.current - 11.months).beginning_of_month
      Employee.includes(:company)
        .where(deleted: false)
        .where('employment_date <= ?', base_date)
        .where.not(company: {retirement_savings_after: [nil, 1]})
        .where.not(id: Notification.where(category: :retirement_savings).select(:employee_id))
    end

    def notice_due?(employee)
      @start_date = employee.employment_date.years_since(employee.company.retirement_savings_after - 1)
      notify_date = @start_date << 1

      today = Date.current
      notify_date.year == today.year && notify_date.month == today.month
    end

    def create_notification_and_user_notifications(employee)
      message = "#{employee.fullname}さんは退職金積立の対象者です。開始時期：#{@start_date.strftime("%Y年%-m月")}"
      @notification = Notification.create!(employee_id: employee.id, category: :retirement_savings, message: message)
      HyaccLogger.info("退職金積立開始のお知らせ生成成功：notification_id=#{@notification.id}, employee_id=#{employee.id}")
      
      User.where(deleted: false).find_each do |user|
        begin
          UserNotification.find_or_create_by!(user_id: user.id, notification_id: @notification.id)
          HyaccLogger.info("退職金積立開始のお知らせ紐づけ成功：notification_id=#{@notification.id}, user_id=#{user.id}")
        rescue => e
          HyaccLogger.error("退職金積立開始のお知らせ紐づけ失敗：notification_id=#{@notification.id}, user_id=#{user.id}, error=#{e.message}")
        end
      end
    end
  end
end