module PayrollNotification
  class PayrollNotificationProcessor

    def self.call
      base_date = Date.current
      HyaccLogger.info("#{base_date.strftime('%Y年%m月%d日')}以降に支払予定の給与明細を対象とします")

      scope = Payroll.where('pay_day >= ? AND is_bonus = ?', base_date, false)
      return unless scope.exists?

      scope.find_each do |payroll|
        new(payroll).process
      end
    end

    def initialize(payroll)
      @ym = payroll.ym
      employee = payroll.employee
      past_ym = (1..3).map{|i| (Date.new(@ym/100, @ym%100, 1) << i).strftime('%Y%m').to_i}
      @past_payrolls = past_ym.map{|ym| Payroll.find_or_initialize_regular_payroll(ym, employee.id)}


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
        cleanup_ad_hoc_revision
        handle_ad_hoc_revision
      end
      handle_annual_determination if @ym % 100 == 9
    end

    private

    def cleanup_ad_hoc_revision
      log_failure_with_block('随時改定の対応チェックとお知らせ更新') do
        PayrollNotification::AdHocRevisionCleaner.call(@context)
      end
    end

    def handle_ad_hoc_revision
      log_failure_with_block('随時改定のお知らせ生成') do
        PayrollNotification::AdHocRevisionHandler.call(@context)
      end
    end

    def handle_annual_determination
      log_failure_with_block('定時決定の対応チェックとお知らせ生成') do
        PayrollNotification::AnnualDeterminationHandler.call(@context)
      end
    end

    def log_failure_with_block(label)
      yield
    rescue => e
      notification_info = @notification ? "notification_id=#{@notification.id}" : "notification=なし"
      HyaccLogger.error("#{label}失敗： #{notification_info} payroll_id=#{@context.payroll.id} #{e.message}")
    end
  end
end