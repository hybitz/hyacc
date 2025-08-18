require 'test_helper'
require 'minitest/mock'

class AnnualDeterminationHandlerTest < ActiveSupport::TestCase
  def setup
    @ym = 202509
    ym_1 = 202508
    @employee = Employee.find(8)
    BankAccount.second.update!(company_id: @employee.company.id, for_payroll: true)
    @employee.company.fiscal_years.find_or_initialize_by(fiscal_year: 2024).save!
    @employee.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025).save!

    pr_1 = Payroll.find_or_initialize_regular_payroll(ym_1, @employee)
    pr_1.update!(monthly_standard: 320_000)
    @payroll = pr_1.reload.dup
    @payroll.ym = @ym
    @payroll.save!

    @past_ym = (1..3).map{|i| (Date.new(@ym/100, @ym%100, 1) << i).strftime('%Y%m').to_i}
    @past_payrolls = @past_ym.map{|ym| Payroll.find_by_ym_and_employee_id(@ym, @employee.id)}
    @context = PayrollNotification::PayrollNotificationContext.new(
      payroll: @payroll,
      ym: @ym,
      employee: @employee,
      past_ym: @past_ym,
      past_payrolls: @past_payrolls
    )

    @notification = Notification.create!(ym: @ym, category: :annual_determination, employee_id: @employee.id, deleted: false)
  end

  def test_随時改定と重複する場合はnotificationを生成しない
    @notification.delete
    notification = Notification.create!(ym: @past_ym[2], category: :ad_hoc_revision, employee_id: @employee.id)
    
    assert_no_changes 'Notification.where(category: :annual_determination).size' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

  end

  def test_先月と当月の標準月額報酬の値が同じであり既存のnotificationのdeletedフラグがfalseである場合はdeletedフラグを更新しない
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    assert_not @notification.reload.deleted?
  end

  def test_先月と当月の標準月額報酬の値が同じであり既存のnotificationのdeletedフラグがtrueである場合はdeletedフラグをfalseに更新する
    @notification.update!(deleted: true)
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    assert_not @notification.reload.deleted?
  end

  def test_先月と当月の標準月額報酬の値が異なり既存のnotificationのdeletedフラグがfalseである場合はdeletedフラグをtrueに更新する
    @payroll.update!(monthly_standard: 340_000)
    assert_not @past_payrolls[0].monthly_standard == @payroll.reload.monthly_standard

    assert_changes '@notification.reload.deleted?' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    assert @notification.reload.deleted?
  end

  def test_先月と当月の標準月額報酬の値が異なり既存のnotificationのdeletedフラグがtrueである場合はdeletedフラグを更新しない
    @notification.update!(deleted: true)
    @payroll.update!(monthly_standard: 340_000)
    assert_not @past_payrolls[0].monthly_standard == @payroll.reload.monthly_standard

    assert_no_changes '@notification.reload.deleted?' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    assert @notification.reload.deleted?
  end

  def test_先月と当月の標準月額報酬の値が異なる場合はnotificationを生成しない
    @notification.delete
    @payroll.update!(monthly_standard: 340_000)
    assert_not @past_payrolls[0].monthly_standard == @payroll.reload.monthly_standard

    assert_no_changes 'Notification.where(category: :annual_determination).size' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_notificationを生成しuserを紐づける
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard
    target_ym = 202505

    pr_may = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.id)
    pr_may.update!(extra_pay: 60_000)

    assert_changes 'Notification.where(category: :annual_determination).size' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    notification = Notification.find_by(employee_id: @payroll.employee_id, ym: @payroll.ym, deleted: false, category: :annual_determination)
    assert notification.present?
    assert_equal "#{@employee.fullname}さんは定時決定の対象者です。適用開始：2025年9月分（2025年10月納付分）", notification.message

    users = User.where(deleted: false)
    assert_equal users.size, UserNotification.where(notification_id: notification.id).size

    users.find_each do |user|
      user_notification = UserNotification.find_by(notification_id: notification.id, user_id: user.id)
      assert user_notification.present?
    end
  end

  def test_notificationの生成とuserとの紐づけの成功ログを出力する
    @notification.delete
    target_ym = 202505

    pr_may = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.id)
    pr_may.update!(extra_pay: 60_000)

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) do |msg|
      msg.include?("定時決定のお知らせ生成成功") &&
      msg.include?("employee_id=#{@payroll.employee_id}")
    end

    User.where(deleted: false).each do |user|
      logger_mock.expect(:info, nil) do |msg|
        msg.include?("定時決定のお知らせ紐づけ成功") &&
        msg.include?("user_id=#{user.id}")
      end
    end

    Rails.stub(:logger, logger_mock) do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end

    logger_mock.verify
  end

  def test_ループ処理は例外が発生しても継続する
    @notification.delete
    target_ym = 202505

    pr_4 = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.id)
    pr_4.update!(extra_pay: 60_000)
  
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
        PayrollNotification::AnnualDeterminationHandler.call(@context)
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
      category: :annual_determination
    )
  
    other_users.each do |user|
      assert UserNotification.exists?(user_id: user.id, notification_id: notification.id)
    end
  end
  
  def test_2月入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202503
    date = Date.new(target_ym / 100, 2, 1)
    @payroll.employee.update!(employment_date: date)
    pr_march = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.id)
    pr_march.update!(extra_pay: 60_000)

    assert_difference 'Notification.where(category: :annual_determination).size', 1 do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_3月1日入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202503
    date = Date.new(target_ym / 100, target_ym % 100, 1)
    @employee.update!(employment_date: date)
    pr_march = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.reload.id)
    pr_march.update!(extra_pay: 60_000)

    assert_difference 'Notification.where(category: :annual_determination).size', 1 do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_3月途中入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202503
    date = Date.new(target_ym / 100, target_ym % 100, 15)
    @employee.update!(employment_date: date)
    pr_march = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.reload.id)
    pr_march.update!(extra_pay: 60_000)

    assert_no_difference 'Notification.where(category: :annual_determination).size' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_4月1日入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202504
    date = Date.new(target_ym / 100, target_ym % 100, 1)
    @employee.update!(employment_date: date)
    pr_april = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.reload.id)
    pr_april.update!(extra_pay: 40_000)

    assert_difference 'Notification.where(category: :annual_determination).size', 1 do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_4月途中入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202504
    date = Date.new(target_ym / 100, target_ym % 100, 15)
    @employee.update!(employment_date: date)
    pr_april = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.reload.id)
    pr_april.update!(extra_pay: 40_000)

    assert_no_difference 'Notification.where(category: :annual_determination).size' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_5月1日入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202505
    date = Date.new(target_ym / 100, target_ym % 100, 1)
    @employee.update!(employment_date: date)
    pr_may = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.reload.id)
    pr_may.update!(extra_pay: 20_000)

    assert_difference 'Notification.where(category: :annual_determination).size', 1 do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

  def test_5月途中入社
    @notification.delete
    assert @past_payrolls[0].monthly_standard == @payroll.monthly_standard

    target_ym = 202505
    date = Date.new(target_ym / 100, target_ym % 100, 15)
    @employee.update!(employment_date: date)
    pr_may = Payroll.find_or_initialize_regular_payroll(target_ym, @employee.reload.id)
    pr_may.update!(extra_pay: 20_000)

    assert_no_difference 'Notification.where(category: :annual_determination).size' do
      PayrollNotification::AnnualDeterminationHandler.call(@context)
    end
  end

end