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
        cleanup_ad_hoc_revision
        handle_ad_hoc_revision
      end
      handle_annual_determination if @ym % 100 == 9
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

  end
end