require 'test_helper'
require 'minitest/mock'

class PayrollNotificationProcessorTest < ActiveSupport::TestCase

  def setup
    @employee8 = Employee.find(8)
    BankAccount.second.update!(company_id: @employee8.company.id, for_payroll: true)
    fy = @employee8.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @ym = 202508

    start_time = 7.days.ago.beginning_of_day
    time_before_start_boundary = Time.at(start_time.to_r - Rational(1, 1_000_000_000))

    end_time = Date.current.beginning_of_day
    time_before_end_boundary = Time.at(end_time.to_r - Rational(1, 1_000_000_000))

    @payroll_updated_within_week = Payroll.find_by(employee_id: @employee8.id, ym: @ym, is_bonus: false)
    @payroll_updated_within_week.update!(updated_at: start_time)

    employee3 = Employee.find(3)
    @payroll_updated_older_than_week = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee3,
      base_salary: 300_000, 
      monthly_standard: 300_000,
      created_at: Date.current,
      create_user_id: employee3.user.id,
      update_user_id: employee3.user.id,
      is_bonus: false
    )
    @payroll_updated_older_than_week.update!(updated_at: time_before_start_boundary)

    employee1 = Employee.first
    fy = employee1.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @payroll_created_within_week = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee1,
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at: time_before_end_boundary,
      create_user_id: employee1.user.id,
      update_user_id: employee1.user.id,
      is_bonus: false
    )

    employee2 = Employee.second
    @payroll_created_today = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee2, 
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at: end_time,
      create_user_id: employee2.user.id,
      update_user_id: employee2.user.id,
      is_bonus: false
    )

    @dummy_logger = Object.new
    def @dummy_logger.info(*); end
    def @dummy_logger.error(*); end
    def @dummy_logger.progname=(_); end

    @processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_updated_within_week.reload, @dummy_logger)
    @past_ym = @processor.instance_variable_get(:@past_ym)
    @past_payrolls = @processor.instance_variable_get(:@past_payrolls)
  end

  def test_initializeとprocessは昨日作成もしくは更新したボーナスではない最新のpayrollレコードがあれば実行される
    called_ids = []
    mocks = []

    PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll, logger) {
      called_ids << payroll.id
      mock = Minitest::Mock.new
      mock.expect(:process, nil)
      mocks << mock
      mock
    }) do
      PayrollNotification::PayrollNotificationProcessor.call(logger: @dummy_logger)
    end

    mocks.each(&:verify)

    assert_includes called_ids, @payroll_updated_within_week.id
    assert_includes called_ids, @payroll_created_within_week.id
    assert_not_includes called_ids, @payroll_created_today.id
    assert_not_includes called_ids, @payroll_updated_older_than_week.id
  end

  def test_initializeとprocessは昨日作成もしくは更新した最新のpayrollレコードがボーナスであれば実行されない
    @payroll_updated_within_week.update!(temporary_salary: 10000, is_bonus: true)
    @payroll_created_within_week.update!(temporary_salary: 10000, is_bonus: true)
    called_ids = []
    mocks = []

    PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll, logger) {
      called_ids << payroll.id
      mock = Minitest::Mock.new
      mock.expect(:process, nil)
      mocks << mock
      mock
    }) do
      PayrollNotification::PayrollNotificationProcessor.call(logger: @dummy_logger)
    end

    mocks.each(&:verify)

    assert_not_includes called_ids, @payroll_updated_within_week.id
    assert_not_includes called_ids, @payroll_created_within_week.id
  end

  def test_initializeとprocessは昨日作成もしくは更新したpayrollレコードが最新でなければ実行されない
    next_month = (Date.new(@ym / 100, @ym % 100, 1).next_month).strftime('%Y%m').to_i

    @payroll_for_next_month = Payroll.create!(
      ym: next_month, 
      pay_day: '2025-10-15', 
      employee: @payroll_updated_within_week.employee, 
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at:  @payroll_updated_within_week.created_at,
      create_user_id: @payroll_updated_within_week.employee.user.id,
      update_user_id:@payroll_updated_within_week.employee.user.id,
      is_bonus: false
    )

    called_ids = []
    mocks = []

    PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll, logger) {
      called_ids << payroll.id
      mock = Minitest::Mock.new
      mock.expect(:process, nil)
      mocks << mock
      mock
    }) do
      PayrollNotification::PayrollNotificationProcessor.call(logger: @dummy_logger)
    end

    mocks.each(&:verify)

    assert_not_includes called_ids, @payroll_updated_within_week.id
  end

  def test_initializeとprocessは昨日作成もしくは更新したpayrollレコードが無ければ実行されない
    Payroll.delete_all

    mock = Minitest::Mock.new
    mock.expect(:process, nil)

    PayrollNotification::PayrollNotificationProcessor.stub(:new, mock) do
      PayrollNotification::PayrollNotificationProcessor.call(logger: @dummy_logger)
    end

    assert_raises(MockExpectationError) { mock.verify }
  end

  def test_ad_hoc_revisionの処理はpast_payrollsがすべてpersistedであれば実行される
    cleanup_called = false
    handle_called = false
  
    cleanup_stub = ->(context:, logger:) {cleanup_called = true}
    handle_stub  = ->(context:, logger:) {handle_called = true}
  
    PayrollNotification::AdHocRevisionCleaner.stub(:call, cleanup_stub) do
      PayrollNotification::AdHocRevisionHandler.stub(:call, handle_stub) do
        assert @processor.instance_variable_get(:@past_payrolls).all?(&:persisted?)
        @processor.process
      end
    end
  
    assert cleanup_called
    assert handle_called 
  end

  def test_ad_hoc_revisionの処理はpast_payrollsがすべてpersistedでないと実行されない
    cleanup_called = false
    handle_called = false
  
    cleanup_stub = ->(context:, logger:) {cleanup_called = true}
    handle_stub  = ->(context:, logger:) {handle_called = true}
  
    @past_payrolls[0].delete
    past_payrolls = @processor.instance_variable_get(:@past_payrolls)
  
    assert_not past_payrolls.all?(&:persisted?)
  
    PayrollNotification::AdHocRevisionCleaner.stub(:call, cleanup_stub) do
      PayrollNotification::AdHocRevisionHandler.stub(:call, handle_stub) do
        @processor.process
      end
    end
  
    assert_not cleanup_called
    assert_not handle_called
  end

  def test_handle_annual_determinationはymが9月の場合のみ実行される
    called_september = false
    PayrollNotification::AnnualDeterminationHandler.stub(:call, ->(context:, logger:) {called_september = true}) do
      @processor.instance_variable_set(:@ym, 202509)
      @processor.process
    end

    assert called_september
  
    called_august = false
    PayrollNotification::AnnualDeterminationHandler.stub(:call, ->(context:, logger:) {called_august = true}) do
      @processor.instance_variable_set(:@ym, 202508)
      @processor.process
    end

    assert_not called_august
  end

  def test_ad_hoc_revision_cleanerの失敗ログを出力する
    expected_message = /随時改定の対応チェックとお知らせ更新失敗：.*payroll_id=#{@payroll_updated_within_week.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}

    @processor.instance_variable_set(:@logger, logger_mock)
    @processor.stub(:cleanup_ad_hoc_revision, -> {processor_mock.call}) do
      @processor.send(:log_failure_with_block, '随時改定の対応チェックとお知らせ更新') do
        @processor.cleanup_ad_hoc_revision
      end
    end
  
    logger_mock.verify
    processor_mock.verify
  end

  def test_ad_hoc_revision_handlerの失敗ログを出力する
    expected_message = /随時改定のお知らせ生成失敗：.*payroll_id=#{@payroll_updated_within_week.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    @processor.instance_variable_set(:@logger, logger_mock)
    @processor.stub(:handle_ad_hoc_revision, -> {processor_mock.call}) do
      @processor.send(:log_failure_with_block, '随時改定のお知らせ生成') do
        @processor.handle_ad_hoc_revision
      end
    end
  
    logger_mock.verify
    processor_mock.verify
  end 

  def test_ad_hoc_revision_handlerのuserとの紐付けの失敗ログを出力する
    pr_1, pr_2, _ = @past_payrolls
    pr_2.update!(housing_allowance: pr_2.housing_allowance + 400000)
    pr_1.update!(housing_allowance: pr_1.housing_allowance + 400000)
    @payroll_updated_within_week.update!(housing_allowance: @payroll_updated_within_week.housing_allowance + 400000)

    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_updated_within_week.reload, @dummy_logger)

    user1 = User.where(deleted: false).first
    user2 = User.where(deleted: false).second
  
    expected_message = /紐づけ失敗:.*user_id=#{user1.id}.*error=テスト用の紐づけ失敗.*user_id=#{user2.id}.*error=テスト用の紐づけ失敗/m

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) { |msg| true }
    logger_mock.expect(:error, nil) { |msg| msg.match?(expected_message) }
    logger_mock.expect(:progname=, nil, [String])

    user_relation_mock = Minitest::Mock.new
    user_relation_mock.expect(:find_each, nil) { |&block| [user1, user2].each(&block) }
  
    UserNotification.stub(:find_or_create_by!, ->(attrs) {
      raise StandardError.new("テスト用の紐づけ失敗")
    }) do
      processor.instance_variable_set(:@logger, logger_mock)
      User.stub(:where, user_relation_mock) do
        processor.send(:log_failure_with_block, '随時改定のお知らせ生成') do
          processor.send(:handle_ad_hoc_revision)
        end
      end
    end

    logger_mock.verify
    user_relation_mock.verify
  end

  def test_annual_determination_handlerの失敗ログを出力する
    expected_message = /定時決定の対応チェックとお知らせ生成失敗：.*payroll_id=#{@payroll_updated_within_week.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    @processor.instance_variable_set(:@logger, logger_mock)
    @processor.stub(:handle_annual_determination, -> {processor_mock.call}) do
      @processor.send(:log_failure_with_block, '定時決定の対応チェックとお知らせ生成') do
        @processor.handle_annual_determination
      end
    end
  
    logger_mock.verify
    processor_mock.verify
  end

  def test_annual_determination_handlerのuserとの紐付けの失敗ログを出力する
    @past_payrolls[0].update!(monthly_standard: 320_000)  
    @payroll_updated_within_week.update!(monthly_standard: 320_000)

    target_ym = 202505
    pr_4 = Payroll.find_or_initialize_regular_payroll(target_ym, @employee8.id)
    pr_4.update!(extra_pay: 60_000)

    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_updated_within_week.reload, @dummy_logger)

    user1 = User.where(deleted: false).first
    user2 = User.where(deleted: false).second
  
    expected_message = /紐づけ失敗:.*user_id=#{user1.id}.*error=テスト用の紐づけ失敗.*user_id=#{user2.id}.*error=テスト用の紐づけ失敗/m

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) { |msg| true }
    logger_mock.expect(:error, nil) { |msg| msg.match?(expected_message) }
    logger_mock.expect(:progname=, nil, [String])
      
    user_relation_mock = Minitest::Mock.new
    user_relation_mock.expect(:find_each, nil) { |&block| [user1, user2].each(&block) }
  
    UserNotification.stub(:find_or_create_by!, ->(attrs) {
      raise StandardError.new("テスト用の紐づけ失敗")
    }) do
      processor.instance_variable_set(:@logger, logger_mock)
      User.stub(:where, user_relation_mock) do
        processor.send(:handle_annual_determination)
      end
    end

    logger_mock.verify
    user_relation_mock.verify
  end

  def test_call内のループ処理は例外が発生しても継続する
    payrolls = [@payroll_created_within_week, @payroll_updated_within_week]
    called_ids = []
    raised = false

    original_new = PayrollNotification::PayrollNotificationProcessor.method(:new)

    PayrollNotification::AdHocRevisionCleaner.stub(:call, ->(context:, logger:) {
      unless raised
        raised = true
        raise 'テスト用の例外'
      end
      true
    }) do
      PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll, logger) {
        processor = original_new.call(payroll, logger)
        called_ids << payroll.id
        processor
      }) do
        assert_nothing_raised do
          PayrollNotification::PayrollNotificationProcessor.call(logger: @dummy_logger)
        end
    
        assert_equal payrolls.map(&:id).sort, called_ids.sort
      end
    end
  end
end