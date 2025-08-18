module PayrollNotification
  class AdHocRevisionHandler
    def self.call(context)
      new(context).execute
    end

    def initialize(context)
      @payroll = context.payroll
      @pr_1, @pr_2, @pr_3 = context.past_payrolls
      @ym = context.ym
      @employee = context.employee
      @effective_ym = Date.new(@ym/100, @ym%100, 1).next_month(2).strftime("%Y%m").to_i
      @effective_payment_ym = Date.new(@ym/100, @ym%100, 1).next_month(3).strftime("%Y%m").to_i
    end

    def execute
      is_applicable = applicable?
      notification_exists = refresh_existing_notification(is_applicable)
      return if !is_applicable || notification_exists
      create_notification_and_user_notifications
    end

    private

    def applicable?
      return false if fixed_salary_stable?

      prefecture_code = @employee.business_office.prefecture_code
      insurance_bs = TaxUtils.get_basic_info(@ym, prefecture_code, @payroll.monthly_standard)
      ave_x = (@payroll.salary_subtotal + @pr_1.salary_subtotal + @pr_2.salary_subtotal)/3
      insurance_x = TaxUtils.get_basic_info(@ym, prefecture_code, ave_x)
      (insurance_bs.grade - insurance_x.grade).abs >= 2
    end

    def refresh_existing_notification(is_applicable)
      @notification = Notification.find_by(
        ym: @ym,
        category: :ad_hoc_revision,
        employee_id: @employee.id
      )
      if @notification
        should_be_deleted = !is_applicable
        @notification.update!(deleted: should_be_deleted) unless @notification.deleted? == should_be_deleted
        return true
      end
      false
    end

    def create_notification_and_user_notifications
      effective_ym_jp = "#{@effective_ym/100}年#{@effective_ym%100}月"
      effective_payment_month_jp ="#{@effective_payment_ym/100}年#{@effective_payment_ym%100}月"

      message = "#{@employee.fullname}さんは随時改定の対象者です。適用開始：#{effective_ym_jp}分（#{effective_payment_month_jp}納付分）" 
      @notification = Notification.create!(message: message, category: :ad_hoc_revision, ym: @ym, employee_id: @employee.id)
      Rails.logger.info("随時改定のお知らせ生成成功: notification_id=#{@notification.id}, employee_id=#{@employee.id}")

      failures = []
      User.where(deleted: false).find_each do |user|
        begin
          UserNotification.find_or_create_by!(user_id: user.id, notification_id: @notification.id)
          Rails.logger.info("随時改定のお知らせ紐づけ成功: notification_id=#{@notification.id}, user_id=#{user.id}")
        rescue => e
          failures << "user_id=#{user.id} error=#{e.message}"
        end    
      end

      if failures.any?
        raise "紐づけ失敗: #{failures.join("\n")}"
      end
    end

    def fixed_salary_stable?
      salary_2 = @pr_2.salary_subtotal - @pr_2.extra_pay
      salary_3 = @pr_3.salary_subtotal - @pr_3.extra_pay
      salary_2 == salary_3
    end

  end
end