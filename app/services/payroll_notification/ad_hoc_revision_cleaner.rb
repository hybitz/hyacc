module PayrollNotification
  class AdHocRevisionCleaner
    def self.call(context)
      new(context).execute
    end

    def initialize(context)
      @payroll = context.payroll
      @pr_1 = context.past_payrolls[0]
      @ym_1 = context.past_ym[0]
      @employee = context.employee
    end

    def execute
      @notification = Notification.find_by(
        ym: @ym_1,
        category: :ad_hoc_revision,
        employee_id: @employee.id
        )

      return unless @notification
      monthly_standard_changed = @payroll.monthly_standard != @pr_1.monthly_standard
      should_be_deleted = monthly_standard_changed
      
      return if @notification.deleted == should_be_deleted
      @notification.update!(deleted: should_be_deleted)
      Rails.logger.info("随時改定の対応チェック 更新成功：notification_id=#{@notification.id}")
    end
  end
end