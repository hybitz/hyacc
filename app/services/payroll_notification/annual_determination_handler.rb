module PayrollNotification
  class AnnualDeterminationHandler
    def self.call(context:, logger:)
      logger.progname = "AnnualDeterminationHandler"
      new(context, logger).execute
    end

    def initialize(context, logger)
      @logger = logger
      @payroll = context.payroll
      @pr_1 = context.past_payrolls[0]
      @ym = context.ym
      @employee = context.employee
    end

    def execute
      monthly_standard_changed = @payroll.monthly_standard != @pr_1.monthly_standard
      return if overlaps_with_ad_hoc_revision? || refresh_existing_notification(monthly_standard_changed)
      return if monthly_standard_changed || annual_determination_applied?
      create_notification_and_user_notifications
    end

    private

    def overlaps_with_ad_hoc_revision?
      base_year = @ym / 100
      target_ym_for_ad_hoc_revision = [5, 6, 7].map{|month| base_year * 100 + month}
      notification =  Notification.where(employee_id: @employee.id, category: :ad_hoc_revision, ym: target_ym_for_ad_hoc_revision)
      Notification.where(employee_id: @employee.id, category: :ad_hoc_revision, ym: target_ym_for_ad_hoc_revision).exists?
    end

    def refresh_existing_notification(monthly_standard_changed)
      notification = Notification.find_by(employee_id: @employee.id, category: :annual_determination, ym: @ym)
      return false unless notification
      should_be_deleted = monthly_standard_changed
      if notification.deleted? != should_be_deleted
        notification.update!(deleted: should_be_deleted) unless notification.deleted? == should_be_deleted
        @logger.info("定時決定の対応チェック 更新成功：notification_id=#{notification.id}")
      end
      true
    end
  
    def annual_determination_applied?
      base_year = @ym /100
      target_ym_for_annnual_determination = [3, 4, 5].map{|month| base_year * 100 + month} 
      month_data = target_ym_for_annnual_determination.map do |ym|
        pr = Payroll.find_or_initialize_regular_payroll(ym, @employee.id)
        [ym, pr]
      end
      x, pr = month_data[0]
      x1, pr1 = month_data[1]
      x2, pr2 = month_data[2]
      
      employment_date = @employee.employment_date
      employment_ym = @employee.employment_date.strftime("%Y%m").to_i
  
      if x > employment_ym || Date.new(x/100, x%100, 1) == employment_date
        bs = (pr.salary_subtotal + pr1.salary_subtotal + pr2.salary_subtotal)/3
      elsif x == employment_ym || Date.new(x1/100, x1%100, 1) == employment_date
        bs = (pr1.salary_subtotal + pr2.salary_subtotal)/2
      elsif x1 == employment_ym || Date.new(x2/100, x2%100, 1) == employment_date
        bs = pr2.salary_subtotal
      else
        return true
      end
      
      prefecture_code = @employee.business_office.prefecture_code
      new_monthly_standard = TaxUtils.get_basic_info(@ym, prefecture_code, bs).monthly_standard
      @payroll.monthly_standard == new_monthly_standard
    end

    def create_notification_and_user_notifications
      ym_jp = "#{@ym/100}年#{@ym%100}月"
      payment_ym = Date.new(@ym/100, @ym%100, 1).next_month.strftime("%Y%m").to_i
      payment_ym_jp = "#{payment_ym/100}年#{payment_ym%100}月"
      message = "#{@employee.fullname}さんは定時決定の対象者です。適用開始：#{ym_jp}分（#{payment_ym_jp}納付分）" 
      @notification = Notification.create!(message: message, category: :annual_determination, ym: @ym, employee_id: @employee.id)
      @logger.info("定時決定のお知らせ生成成功: notification_id=#{@notification.id}, employee_id=#{@employee.id}")

      failures = []
      User.where(deleted: false).find_each do |user|
        begin
          UserNotification.find_or_create_by!(user_id: user.id, notification_id: @notification.id)
          @logger.info("定時決定のお知らせ紐づけ成功: notification_id=#{@notification.id}, user_id=#{user.id}")
        rescue => e
          failures << "user_id=#{user.id} error=#{e.message}"
        end    
      end

      if failures.any?
        raise "紐づけ失敗: #{failures.join("\n")}"
      end
    end

  end
end