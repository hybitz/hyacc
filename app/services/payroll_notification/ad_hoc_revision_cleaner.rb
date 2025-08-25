module PayrollNotification
  class AdHocRevisionCleaner
    def self.call(context:, logger:)
      logger.progname = "AdHocRevisionCleaner"
      new(context, logger).execute
    end

    def initialize(context, logger)
      @logger = logger
      @payroll = context.payroll
      @pr_1 = context.past_payrolls[0]
      @pr_2 = context.past_payrolls[1]
      @pr_3 = context.past_payrolls[2]
      @ym_2 = context.past_ym[1]
      @employee = context.employee
    end

    def execute
      @notification = Notification.find_by(
        ym: @ym_2,
        category: :ad_hoc_revision,
        employee_id: @employee.id
        )

      return unless @notification

      monthly_standard_changed = @payroll.monthly_standard != @pr_1.monthly_standard
      should_be_deleted = monthly_standard_changed

      if should_be_deleted_based_on_annual_determination?
        should_be_deleted = true
      end
      
      return if @notification.deleted == should_be_deleted
      @notification.update!(deleted: should_be_deleted)
      @logger.info("随時改定の対応チェック 更新成功：notification_id=#{@notification.id}")
    end

    private

    def should_be_deleted_based_on_annual_determination?
      return false unless @notification.ym % 100 == 8
      return false unless @pr_1.monthly_standard != @pr_2.monthly_standard
  
      ym_4 = (@ym_2 / 100) * 100 + 6
      pr_4 = Payroll.find_or_initialize_regular_payroll(ym_4, @employee.id)
  
      ave_x = (@pr_2.salary_subtotal + @pr_3.salary_subtotal + pr_4.salary_subtotal) / 3
      prefecture_code = @employee.business_office.prefecture_code
      insurance_x = TaxUtils.get_basic_info(@ym_2, prefecture_code, ave_x)
  
      @pr_1.monthly_standard == insurance_x.monthly_standard
    end
  end
end