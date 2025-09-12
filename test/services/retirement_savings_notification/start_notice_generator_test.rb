require 'test_helper'
require 'minitest/mock'

class StartNoticeGeneratorTest < ActiveSupport::TestCase
  def setup
    @base_date = Date.current - 1.year - 11.months
    employee.update!(employment_date: @base_date)
  end

  def test_create_notification_and_user_notifications
    assert_difference 'Notification.where(category: :retirement_savings, deleted: false).size', 1 do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end

    notification = Notification.last
    start_date = employee.employment_date.years_since(employee.company.retirement_savings_after - 1)
    assert_equal "#{employee.fullname}さんは退職金積立の対象者です。開始時期：#{start_date.strftime("%Y年%-m月")}", notification.message
    assert_equal employee.id, notification.employee_id

    users = User.where(deleted: false)
    assert_equal users.size, UserNotification.where(notification_id: notification.id).size

    users.find_each do |user|
      user_notification = UserNotification.find_by(notification_id: notification.id, user_id: user.id)
      assert user_notification.present?
    end
  end

  def test_does_not_raise_error_when_notification_already_exists
    notification = Notification.create!(category: :retirement_savings, employee_id: employee.id)
    assert_nothing_raised do
      assert_no_difference 'Notification.where(category: :retirement_savings, deleted: false).size' do
        RetirementSavingsNotification::StartNoticeGenerator.call
      end
    end
  end

  def test_skips_generate_task_when_no_target_employees
    employee.company.update!(retirement_savings_after: nil)
    assert_no_difference 'Notification.where(category: :retirement_savings, deleted: false).size' do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end

    employee.company.update!(retirement_savings_after: 1)
    assert_no_difference 'Notification.where(category: :retirement_savings, deleted: false).size' do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end
  end

  def test_creates_on_boundary_values_and_skips_out_of_range
    employee.company.update!(retirement_savings_after: 2)

    date = (Date.current - 10.month).end_of_month
    employee.update!(employment_date: date)
    assert_no_difference 'Notification.where(category: :retirement_savings, deleted: false).size' do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end

    date = (Date.current - 1.year).beginning_of_month
    employee.update!(employment_date: date)
    assert_no_difference 'Notification.where(category: :retirement_savings, deleted: false).size' do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end

    date = (Date.current - 11.months).beginning_of_month
    employee.update!(employment_date: date)
    assert_difference 'Notification.where(category: :retirement_savings, deleted: false).size', 1 do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end
  end

  def test_logs_success_on_notification_creation_and_user_association 
    messages = []

    HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
      RetirementSavingsNotification::StartNoticeGenerator.call
    end

    assert messages.any?{|msg|msg.match?(/\A退職金積立開始のお知らせ生成成功：notification_id=\d+, employee_id=#{employee.id}\z/)}

    User.where(deleted: false).each do |user|
      assert messages.any?{|msg|msg.match?(/\A退職金積立開始のお知らせ紐づけ成功：notification_id=\d+, user_id=#{user.id}\z/)}
    end
  end

  def test_skips_user_association_if_notification_creation_fails
    messages = []
    call_count = 0

    UserNotification.stub(:find_or_create_by!, ->(_) {call_count += 1}) do
      Notification.stub(:create!, ->(*) {raise 'テスト用例外'}) do
        HyaccLogger.stub(:error, ->(msg) {messages << msg}) do
          RetirementSavingsNotification::StartNoticeGenerator.call
        end
      end
    end
    assert messages.any?{|msg| msg =="退職金積立開始のお知らせ生成失敗：notification=なし, employee_id=#{employee.id}, error=テスト用例外"}
    assert_equal 0, call_count
  end

  def test_notification_creation_loop_continues_after_exeption
    messages = []
    success_employee = Employee.where(deleted: false, company_id: employee.company.id).second
    success_employee.update!(employment_date: @base_date)

    original_method = Notification.method(:create!)
    Notification.stub(:create!, ->(args) {
      if args[:employee_id] == employee.id
        raise "テスト用例外" 
      else
        original_method.call(args)
      end
    }) do
      HyaccLogger.stub(:error, ->(msg) {messages << msg}) do
        HyaccLogger.stub(:info,  ->(msg) {messages << msg}) do
          RetirementSavingsNotification::StartNoticeGenerator.call
        end
      end
    end

    assert messages.any?{|msg|msg =="退職金積立開始のお知らせ生成失敗：notification=なし, employee_id=#{employee.id}, error=テスト用例外"}
    assert messages.any?{|msg|msg.match?(/\A退職金積立開始のお知らせ生成成功：notification_id=\d+, employee_id=#{success_employee.id}\z/)}
  end

  def test_user_association_loop_continues_after_exception
    messages = []
    target_user = User.where(deleted: false).second

    original_method = UserNotification.method(:find_or_create_by!)
    UserNotification.stub(:find_or_create_by!, ->(args) {
      if args[:user_id] == target_user.id
        raise "テスト用例外"
      else
        original_method.call(args)
      end
    }) do
      HyaccLogger.stub(:error, ->(msg) {messages << msg}) do
        HyaccLogger.stub(:info,  ->(msg) {messages << msg}) do
          RetirementSavingsNotification::StartNoticeGenerator.call
        end
      end
    end

    assert messages.any?{|msg| msg.match?(/\A退職金積立開始のお知らせ紐づけ失敗：notification_id=\d+, user_id=#{target_user.id}, error=テスト用例外\z/)}

    User.where(deleted: false).where.not(id: target_user.id).each do |user|
      assert messages.any?{|msg| msg.match?(/\A退職金積立開始のお知らせ紐づけ成功：notification_id=\d+, user_id=#{user.id}\z/)}
    end
  end
end
