require 'test_helper'
require 'minitest/mock'

class AdHocRevisionHandlerTest < ActiveSupport::TestCase
  def setup
    ym = 202508
    employee = Employee.find(8)
    BankAccount.second.update!(company_id: employee.company.id, for_payroll: true)
    employee.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025).save!

    @payroll = Payroll.find_by(ym: ym, employee_id: employee.id)
    @payroll.update!(monthly_standard: @payroll.base_salary)
    past_ym = (1..3).map{|i| (Date.new(ym/100, ym%100, 1) << i).strftime('%Y%m').to_i}
    @past_payrolls = past_ym.map{|ym| Payroll.find_by_ym_and_employee_id(ym, employee.id)}
    @context = PayrollNotification::PayrollNotificationContext.new(
      payroll: @payroll.reload,
      ym: ym,
      employee: employee,
      past_ym: past_ym,
      past_payrolls: @past_payrolls
    )

    @pr_1, @pr_2, @pr_3 = @past_payrolls
    @notification = Notification.create!(ym: ym, category: :ad_hoc_revision, employee_id: employee.id, deleted: false)

    @dummy_logger = Object.new
    def @dummy_logger.info(*); end
    def @dummy_logger.progname=(_); end
  end

  def test_固定的賃金に変動がない場合かつ既存のnotificationのdeletedフラグがfalseである場合はdeletedフラグをtrueに更新する
    assert (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) do |msg|
      msg.include?("随時改定の対応チェック 更新成功") &&
      msg.include?("notification_id=#{@notification.id}")
    end
    logger_mock.expect(:progname=, nil, ["AdHocRevisionHandler"])

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: logger_mock)
    end

    assert @notification.reload.deleted?
    logger_mock.verify
  end

  def test_固定的賃金に変動がない場合かつ既存のnotificationのdeletedフラグがtrueである場合はdeletedフラグを更新しない
    @notification.update!(deleted: true)
    assert (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)

    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @dummy_logger)
    end

    assert @notification.reload.deleted?
  end

  def test_固定的賃金に変動がない場合はnotificationを生成しない
    UserNotification.delete_all
    Notification.delete_all
    assert (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)

    assert_no_difference 'Notification.count' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @dummy_logger)
    end
  end

  def test_固定的賃金に変動があり随時改定の条件を満たさず既存のnotificationのdeletedフラグがtrueである場合はdeletedフラグを更新しない
    @notification.update!(deleted: true)

    @pr_2.update!(housing_allowance: @pr_2.commuting_allowance + 1000)
    assert_not (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)
    @context.past_payrolls = @past_payrolls.map(&:reload)

    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @dummy_logger)
    end

    assert @notification.deleted?
  end

  def test_固定的賃金に変動があり随時改定の条件を満たさず既存のnotificationのdeletedフラグがfalseである場合はdeletedフラグをtrueに更新する
    @pr_2.update!(housing_allowance: @pr_2.commuting_allowance + 1000)
    assert_not (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)
    @context.past_payrolls = @past_payrolls.map(&:reload)

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) do |msg|
      msg.include?("随時改定の対応チェック 更新成功") &&
      msg.include?("notification_id=#{@notification.id}")
    end
    logger_mock.expect(:progname=, nil, ["AdHocRevisionHandler"])

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: logger_mock)
    end

    assert @notification.deleted?
    logger_mock.verify
  end

  def test_随時改定の条件を満たし既存のnotificationのdeletedフラグがfalseである場合はdeletedフラグを更新しない
    @pr_2.update!(housing_allowance: @pr_2.housing_allowance + 400000)
    @pr_1.update!(housing_allowance: @pr_1.housing_allowance + 400000)
    @payroll.update!(housing_allowance: @payroll.housing_allowance + 400000)
  
    assert_not (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)
    @context.past_payrolls = @past_payrolls.map(&:reload)
    @context.payroll = @payroll.reload
    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @dummy_logger)
    end

    assert_not @notification.deleted?
  end

  def test_随時改定の条件を満たし既存のnotificationのdeletedフラグがtrueである場合はdeletedフラグをfalseに更新する
    @notification.update!(deleted: true)

    @pr_2.update!(housing_allowance: @pr_2.housing_allowance + 400000)
    @pr_1.update!(housing_allowance: @pr_1.housing_allowance + 400000)
    @payroll.update!(housing_allowance: @payroll.housing_allowance + 400000)
  
    assert_not (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)
    @context.past_payrolls = @past_payrolls.map(&:reload)
    @context.payroll = @payroll.reload

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) do |msg|
      msg.include?("随時改定の対応チェック 更新成功") &&
      msg.include?("notification_id=#{@notification.id}")
    end
    logger_mock.expect(:progname=, nil, ["AdHocRevisionHandler"])

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: logger_mock)
    end

    assert_not @notification.deleted?
    logger_mock.verify
  end

  def test_notificationを生成しuserと紐づける
    UserNotification.delete_all
    Notification.delete_all

    @pr_2.update!(housing_allowance: @pr_2.housing_allowance + 400000)
    @pr_1.update!(housing_allowance: @pr_1.housing_allowance + 400000)
    @payroll.update!(housing_allowance: @payroll.housing_allowance + 400000) 
    assert_not (@pr_3.salary_subtotal - @pr_3.extra_pay) == (@pr_2.salary_subtotal - @pr_2.extra_pay)

    @context.past_payrolls = @past_payrolls.map(&:reload)
    @context.payroll = @payroll.reload

    assert_difference 'Notification.count' do
      PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @dummy_logger)
    end

    notification = Notification.find_by(employee_id: @payroll.employee_id, ym: @payroll.ym, deleted: false, category: :ad_hoc_revision)
    assert notification.present?
    assert_equal "#{@payroll.employee.fullname}さんは随時改定の対象者です。適用開始：2025年10月分（2025年11月納付分）", notification.message

    users = User.where(deleted: false)
    assert_equal users.size, UserNotification.where(notification_id: notification.id).size
    
    users.find_each do |user|
      user_notification = UserNotification.find_by(notification_id: notification.id, user_id: user.id)
      assert user_notification.present?
    end
  end

  def test_notificationの生成とuserとの紐づけの成功ログを出力する
    UserNotification.delete_all
    Notification.delete_all

    @pr_2.update!(housing_allowance: @pr_2.housing_allowance + 400000)
    @pr_1.update!(housing_allowance: @pr_1.housing_allowance + 400000)
    @payroll.update!(housing_allowance: @payroll.housing_allowance + 400000) 

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) do |msg|
      msg.include?("随時改定のお知らせ生成成功") &&
      msg.include?("employee_id=#{@payroll.employee_id}")
    end
    logger_mock.expect(:progname=, nil, ["AdHocRevisionHandler"])

    User.where(deleted: false).each do |user|
      logger_mock.expect(:info, nil) do |msg|
        msg.include?("随時改定のお知らせ紐づけ成功") &&
        msg.include?("user_id=#{user.id}")
      end
    end

    @context.past_payrolls = @past_payrolls.map(&:reload)
    @context.payroll = @payroll.reload

    PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: logger_mock)

    logger_mock.verify
  end

  def test_ループ処理は例外が発生しても継続する
    UserNotification.delete_all
    Notification.delete_all
  
    @pr_2.update!(housing_allowance: @pr_2.housing_allowance + 400_000)
    @pr_1.update!(housing_allowance: @pr_1.housing_allowance + 400_000)
    @payroll.update!(housing_allowance: @payroll.housing_allowance + 400_000)
  
    @context.past_payrolls = @past_payrolls.map(&:reload)
    @context.payroll = @payroll.reload
  
    failing_user = User.where(deleted: false).first
    other_users = User.where(deleted: false).where.not(id: failing_user.id)
  
    called_user_ids = []
    error = nil
  
    UserNotification.stub :find_or_create_by!, ->(attrs) {
      user_id = attrs[:user_id]
      called_user_ids << user_id
      raise "テスト用の例外" if user_id == failing_user.id
      UserNotification.create!(attrs)
    } do
      error = assert_raises RuntimeError do
        PayrollNotification::AdHocRevisionHandler.call(context: @context, logger: @dummy_logger)
      end
    end

    expected_message = "紐づけ失敗: user_id=#{failing_user.id} error=テスト用の例外"
    assert_match expected_message, error.message    

    assert_includes called_user_ids, failing_user.id
    assert_equal User.where(deleted: false).pluck(:id).sort, called_user_ids.sort
  
    notification = Notification.find_by(
      employee_id: @payroll.employee_id,
      ym: @payroll.ym,
      deleted: false,
      category: :ad_hoc_revision
    )
  
    other_users.each do |user|
      assert UserNotification.exists?(user_id: user.id, notification_id: notification.id)
    end
  end
end