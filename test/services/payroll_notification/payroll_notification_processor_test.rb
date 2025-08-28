require 'test_helper'
require 'minitest/mock'

class PayrollNotificationProcessorTest < ActiveSupport::TestCase

  def setup
    @employee8 = Employee.find(8)
    BankAccount.second.update!(company_id: @employee8.company.id, for_payroll: true)
    fy = @employee8.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    ym = 202508

    @base_date = Date.current
    date_before_base_date = @base_date - 1

    @payroll_with_pay_day_on_base_date = Payroll.find_by(employee_id: @employee8.id, ym: ym, is_bonus: false)
    @payroll_with_pay_day_on_base_date.update!(pay_day: @base_date)

    employee1 = Employee.first
    fy = employee1.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @payroll_with_pay_day_before_base_date = Payroll.create!(
      ym: ym, 
      pay_day: date_before_base_date, 
      employee: employee1,
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      create_user_id: employee1.user.id,
      update_user_id: employee1.user.id,
      is_bonus: false
    )
  end

  def test_処理対象に関するログを出力する
    mock = Minitest::Mock.new
    mock.expect(:process, nil)

    expected_message = "#{@base_date.strftime('%Y年%m月%d日')}以降に支払予定の給与明細を対象とします"
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil, [expected_message])

    PayrollNotification::PayrollNotificationProcessor.stub(:new, mock) do
      HyaccLogger.stub(:info, ->(msg) {logger_mock.info(msg)}) do
        PayrollNotification::PayrollNotificationProcessor.call
      end
    end

    logger_mock.verify
  end

  def test_initializeとprocessは実行日以降に支払予定の給与明細であれば実行する
    called_ids = []
    mocks = []

    PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll) {
      called_ids << payroll.id
      mock = Minitest::Mock.new
      mock.expect(:process, nil)
      mocks << mock
      mock
    }) do
      PayrollNotification::PayrollNotificationProcessor.call
    end

    mocks.each(&:verify)

    assert_includes called_ids, @payroll_with_pay_day_on_base_date.id
    assert_not_includes called_ids, @payroll_with_pay_day_before_base_date.id
  end

  def test_initializeとprocessは実行日以降に支払予定のボーナス明細であれば実行しない
    @payroll_with_pay_day_on_base_date.update!(temporary_salary: 10000, is_bonus: true)
    called_ids = []
    mocks = []

    PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll) {
      called_ids << payroll.id
      mock = Minitest::Mock.new
      mock.expect(:process, nil)
      mocks << mock
      mock
    }) do
      PayrollNotification::PayrollNotificationProcessor.call
    end

    mocks.each(&:verify)

    assert_not_includes called_ids, @payroll_with_pay_day_on_base_date.id
  end

  def test_initializeとprocessは実行日以降に支払予定の給与明細がなければ実行しない
    Payroll.delete_all

    mock = Minitest::Mock.new
    mock.expect(:process, nil)

    PayrollNotification::PayrollNotificationProcessor.stub(:new, mock) do
      PayrollNotification::PayrollNotificationProcessor.call
    end

    assert_raises(MockExpectationError) {mock.verify}
  end

  def test_ad_hoc_revisionの処理はpast_payrollsがすべてpersistedであれば実行される
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)

    cleanup_called = false
    handle_called = false
  
    cleanup_stub = ->(context) {cleanup_called = true}
    handle_stub  = ->(context) {handle_called = true}
  
    PayrollNotification::AdHocRevisionCleaner.stub(:call, cleanup_stub) do
      PayrollNotification::AdHocRevisionHandler.stub(:call, handle_stub) do
        assert processor.instance_variable_get(:@past_payrolls).all?(&:persisted?)
        processor.process
      end
    end
  
    assert cleanup_called
    assert handle_called 
  end

  def test_ad_hoc_revisionの処理はpast_payrollsがすべてpersistedでないと実行されない
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)
    past_payrolls = processor.instance_variable_get(:@past_payrolls)

    cleanup_called = false
    handle_called = false
  
    cleanup_stub = ->(context) {cleanup_called = true}
    handle_stub  = ->(context) {handle_called = true}
  
    past_payrolls[0].delete
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)
  
    PayrollNotification::AdHocRevisionCleaner.stub(:call, cleanup_stub) do
      PayrollNotification::AdHocRevisionHandler.stub(:call, handle_stub) do
        processor.process
      end
    end

    assert_not cleanup_called
    assert_not handle_called
  end

  def test_handle_annual_determinationはymが9月の場合のみ実行される
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)

    called_september = false
    PayrollNotification::AnnualDeterminationHandler.stub(:call, ->(context) {called_september = true}) do
      processor.instance_variable_set(:@ym, 202509)
      processor.process
    end

    assert called_september
  
    called_august = false
    PayrollNotification::AnnualDeterminationHandler.stub(:call, ->(context) {called_august = true}) do
      processor.instance_variable_set(:@ym, 202508)
      processor.process
    end

    assert_not called_august
  end

  def test_ad_hoc_revision_cleanerの失敗ログを出力する
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)

    expected_message = /随時改定の対応チェックとお知らせ更新失敗：.*payroll_id=#{@payroll_with_pay_day_on_base_date.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}

    HyaccLogger.stub(:error, -> (msg){logger_mock.error(msg)}) do
      processor.stub(:cleanup_ad_hoc_revision, -> {processor_mock.call}) do
        processor.send(:log_failure_with_block, '随時改定の対応チェックとお知らせ更新') do
          processor.cleanup_ad_hoc_revision
        end
      end
    end
  
    logger_mock.verify
    processor_mock.verify
  end

  def test_ad_hoc_revision_handlerの失敗ログを出力する
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)

    expected_message = /随時改定のお知らせ生成失敗：.*payroll_id=#{@payroll_with_pay_day_on_base_date.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    HyaccLogger.stub(:error, -> (msg){logger_mock.error(msg)}) do
      processor.stub(:handle_ad_hoc_revision, -> {processor_mock.call}) do
        processor.send(:log_failure_with_block, '随時改定のお知らせ生成') do
          processor.handle_ad_hoc_revision
        end
      end
    end
  
    logger_mock.verify
    processor_mock.verify
  end 

  def test_ad_hoc_revision_handlerのuserとの紐付けの失敗ログを出力する
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)
    past_payrolls = processor.instance_variable_get(:@past_payrolls)

    pr_1, pr_2, _ = past_payrolls
    pr_2.update!(housing_allowance: pr_2.housing_allowance + 400000)
    pr_1.update!(housing_allowance: pr_1.housing_allowance + 400000)
    @payroll_with_pay_day_on_base_date.update!(housing_allowance: @payroll_with_pay_day_on_base_date.housing_allowance + 400000)

    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date.reload)

    user1 = User.where(deleted: false).first
    user2 = User.where(deleted: false).second
  
    expected_message = /紐づけ失敗:.*user_id=#{user1.id}.*error=テスト用の紐づけ失敗.*user_id=#{user2.id}.*error=テスト用の紐づけ失敗/m

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}

    user_relation_mock = Minitest::Mock.new
    user_relation_mock.expect(:find_each, nil) {|&block| [user1, user2].each(&block)}
  
    UserNotification.stub(:find_or_create_by!, ->(attrs) {
      raise StandardError.new("テスト用の紐づけ失敗")
    }) do
      HyaccLogger.stub(:error, -> (msg){logger_mock.error(msg)}) do
        User.stub(:where, user_relation_mock) do
          processor.send(:log_failure_with_block, '随時改定のお知らせ生成') do
            processor.send(:handle_ad_hoc_revision)
          end
        end
      end
    end

    logger_mock.verify
    user_relation_mock.verify
  end

  def test_annual_determination_handlerの失敗ログを出力する
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)

    expected_message = /定時決定の対応チェックとお知らせ生成失敗：.*payroll_id=#{@payroll_with_pay_day_on_base_date.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    HyaccLogger.stub(:error, -> (msg){logger_mock.error(msg)}) do
      processor.stub(:handle_annual_determination, -> {processor_mock.call}) do
        processor.send(:log_failure_with_block, '定時決定の対応チェックとお知らせ生成') do
          processor.handle_annual_determination
        end
      end
    end
  
    logger_mock.verify
    processor_mock.verify
  end

  def test_annual_determination_handlerのuserとの紐付けの失敗ログを出力する
    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)
    past_payrolls = processor.instance_variable_get(:@past_payrolls)

    past_payrolls[0].update!(monthly_standard: 320_000)  
    @payroll_with_pay_day_on_base_date.update!(monthly_standard: 320_000)

    target_ym = 202505
    pr_4 = Payroll.find_or_initialize_regular_payroll(target_ym, @employee8.id)
    pr_4.update!(extra_pay: 60_000)

    processor = PayrollNotification::PayrollNotificationProcessor.new(@payroll_with_pay_day_on_base_date)

    user1 = User.where(deleted: false).first
    user2 = User.where(deleted: false).second
  
    expected_message = /紐づけ失敗:.*user_id=#{user1.id}.*error=テスト用の紐づけ失敗.*user_id=#{user2.id}.*error=テスト用の紐づけ失敗/m

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) { |msg| msg.match?(expected_message) }
      
    user_relation_mock = Minitest::Mock.new
    user_relation_mock.expect(:find_each, nil) { |&block| [user1, user2].each(&block) }
  
    UserNotification.stub(:find_or_create_by!, ->(attrs) {
      raise StandardError.new("テスト用の紐づけ失敗")
    }) do
      HyaccLogger.stub(:error, -> (msg){logger_mock.error(msg)}) do
        User.stub(:where, user_relation_mock) do
          processor.send(:handle_annual_determination)
        end
      end
    end

    logger_mock.verify
    user_relation_mock.verify
  end

  def test_call内のループ処理は例外が発生しても継続する
    @payroll = @payroll_with_pay_day_before_base_date
    @payroll.update!(pay_day: @base_date)

    payrolls = [@payroll, @payroll_with_pay_day_on_base_date]
    called_ids = []
    raised = false

    original_new = PayrollNotification::PayrollNotificationProcessor.method(:new)
    PayrollNotification::AdHocRevisionCleaner.stub(:call, ->(context) {
      unless raised
        raised = true
        raise 'テスト用の例外'
      end
      true
    }) do
      PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll) {
        processor = original_new.call(payroll)
        called_ids << payroll.id
        processor
      }) do
        assert_nothing_raised do
          PayrollNotification::PayrollNotificationProcessor.call
        end

        assert_equal payrolls.map(&:id).sort, called_ids.sort
      end
    end
  end
end