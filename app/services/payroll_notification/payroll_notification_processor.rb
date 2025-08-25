module PayrollNotification
  class PayrollNotificationProcessor

    def self.call(logger:)
      start_time = 7.days.ago.beginning_of_day
      end_time = Date.current.beginning_of_day

      scope = Payroll.where(created_at: start_time...end_time, is_bonus: false)
      .or(Payroll.where(updated_at: start_time...end_time, is_bonus: false))

      period_message = "対象期間：#{start_time.strftime('%Y-%m-%d')} ~ #{end_time.strftime('%Y-%m-%d')}（※終了日は含まない）"
      action_message = "この期間に作成・更新された最新のPayrollを処理対象とします" 
      logger.progname = "PayrollNotificationProcessor"
      logger.info("#{period_message} - #{action_message}")

      return unless scope.exists?

      scope.find_each do |payroll|
        next_ym = (Date.new(payroll.ym / 100, payroll.ym % 100, 1).next_month).strftime('%Y%m').to_i
        next if Payroll.exists?(ym: next_ym, employee_id: payroll.employee_id, is_bonus: false)
      
        new(payroll, logger).process  
      end
    end

    def initialize(payroll, logger)
      @logger = logger
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
        PayrollNotification::AdHocRevisionCleaner.call(context: @context, logger: @logger)
      end
    end

    def handle_ad_hoc_revision
      log_failure_with_block('随時改定のお知らせ生成') do
        PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @logger)
      end
    end

    def handle_annual_determination
      log_failure_with_block('定時決定の対応チェックとお知らせ生成') do
        PayrollNotification::AnnualDeterminationHandler.call(context: @context, logger: @logger)
      end
    end

    def log_failure_with_block(label)
      yield
    rescue => e
      notification_info = @notification ? "notification_id=#{@notification.id}" : "notification=なし"
      @logger.error("#{label}失敗： #{notification_info} payroll_id=#{@context.payroll.id} #{e.message}")
    end
  end
end