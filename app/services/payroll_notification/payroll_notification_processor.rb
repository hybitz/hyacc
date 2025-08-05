module PayrollNotification
  class PayrollNotificationProcessor

    def self.call
      yesterday = Date.yesterday

      scope = Payroll.where(created_at: yesterday.all_day)
      .or(Payroll.where(updated_at: yesterday.all_day))

      return unless scope.exists?

      scope.find_each do |payroll|
        new(payroll).process
      end
    end

    def initialize(payroll)
      @ym = payroll.ym
      employee = payroll.employee
      past_ym = (1..3).map{|i| (Date.new(@ym/100, @ym%100, 1) << i).strftime('%Y%m').to_i}
      @past_payrolls = past_ym.map{|ym| Payroll.find_by_ym_and_employee_id(@ym, employee.id)}


      @context = PayrollNotificationContext.new(
        payroll: payroll,
        ym: @ym,
        employee: employee,
        past_ym: past_ym,
        past_payrolls: @past_payrolls
      )
    end

    def process
      if @past_payrolls.all?(&:persisted?)
        log_failure(:cleanup_ad_hoc_revision, '随時改定の対応チェックとお知らせ更新')
        log_failure(:handle_ad_hoc_revision, '随時改定のお知らせ生成')
      end
      log_failure(:handle_annual_determination, '定時決定の対応チェックとお知らせ生成') if @ym % 100 == 9
    end

    private

    def cleanup_ad_hoc_revision
      PayrollNotification::AdHocRevisionCleaner.call(@context)
    end

    def handle_ad_hoc_revision
      PayrollNotification::AdHocRevisionHandler.call(@context)
    end

    def handle_annual_determination
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    def log_failure(method, label)
      send(method)
    rescue => e
      notification_info = @notification ? "notification_id=#{@notification.id}" : "notification=なし"
      Rails.logger.error("#{label}失敗： #{notification_info} payroll_id=#{@context.payroll.id} #{e.message}")
    end
  end
end