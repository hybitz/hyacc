require 'test_helper'
require 'minitest/mock'

class PayrollNotificationProcessorTest < ActiveSupport::TestCase

  def setup
    @employee8 = Employee.find(8)
    BankAccount.second.update!(company_id: @employee8.company.id, for_payroll: true)
    fy = @employee8.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @ym = 202508

    start_time = Date.yesterday.beginning_of_day
    time_before_start_boundary = Time.at(start_time.to_r - Rational(1, 1_000_000_000))

    end_time = Date.current.beginning_of_day
    time_before_end_boundary = Time.at(end_time.to_r - Rational(1, 1_000_000_000))

    @payroll_updated_yesterday = Payroll.find_by(employee_id: @employee8.id, ym: @ym)
    @payroll_updated_yesterday.update!(updated_at: start_time)

    @payroll_updated_two_days_ago = Payroll.find_by(employee_id: @employee8.id, ym: 202507)
    @payroll_updated_two_days_ago.update!(updated_at: time_before_start_boundary)

    employee1 = Employee.first
    fy = employee1.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @payroll_created_yesterday = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee1,
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at: time_before_end_boundary,
      create_user_id: employee1.user.id,
      update_user_id: employee1.user.id)

    employee2 = Employee.second
    @payroll_created_today = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee2, 
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at: end_time,
      create_user_id: employee2.user.id,
      update_user_id: employee2.user.id)

    @processor = PayrollNotification::PayrollNotificationProcessor.allocate
  
    past_ym = (1..3).map { |i| (Date.new(@ym / 100, @ym % 100, 1) << i).strftime('%Y%m').to_i }
    past_payrolls = past_ym.map { |ym| Payroll.find_by_ym_and_employee_id(@ym, @employee8.id) }
  
    @context = PayrollNotification::PayrollNotificationContext.new(
      payroll: @payroll_updated_yesterday,
      ym: @ym,
      employee: @employee8,
      past_ym: past_ym,
      past_payrolls: past_payrolls
    )
  end

  def test_initializeとprocessは昨日作成もしくは更新したpayrollレコードがあれば実行される
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

    assert_includes called_ids, @payroll_updated_yesterday.id
    assert_includes called_ids, @payroll_created_yesterday.id
    assert_not_includes called_ids, @payroll_created_today.id
    assert_not_includes called_ids, @payroll_updated_two_days_ago.id
  end

  def test_initializeとprocessは昨日作成もしくは更新したpayrollレコードが無ければ実行されない
    Payroll.delete_all

    mock = Minitest::Mock.new
    mock.expect(:process, nil)

    PayrollNotification::PayrollNotificationProcessor.stub(:new, mock) do
      PayrollNotification::PayrollNotificationProcessor.call
    end

    assert_raises(MockExpectationError) { mock.verify }
  end

  def test_ad_hoc_revisionの処理はpast_payrollsがすべてpersistedであれば実行される
    cleanup_ad_hoc_revision_mock = Minitest::Mock.new
    handle_ad_hoc_revision_mock = Minitest::Mock.new
  
    context = Minitest::Mock.new

    past_ym = (1..3).map{|i| (Date.new(@ym/100, @ym%100, 1) << i).strftime('%Y%m').to_i}
    persisted_past_payrolls = past_ym.map{|ym| Payroll.find_by(ym: @ym, employee_id: @employee8.id)}
    assert persisted_past_payrolls.all?(&:persisted?)

  
    cleanup_ad_hoc_revision_mock.expect(:call, nil, [context])
    handle_ad_hoc_revision_mock.expect(:call, nil, [context])
  
    @processor.instance_variable_set(:@past_payrolls, persisted_past_payrolls)
    @processor.instance_variable_set(:@ym, @ym)
    @processor.instance_variable_set(:@context, context)
  
    PayrollNotification::AdHocRevisionCleaner.stub(:call, cleanup_ad_hoc_revision_mock) do
      PayrollNotification::AdHocRevisionHandler.stub(:call, handle_ad_hoc_revision_mock) do
        @processor.process
      end
    end
  
    cleanup_ad_hoc_revision_mock.verify
    handle_ad_hoc_revision_mock.verify
  end

  def test_ad_hoc_revisionの処理はpast_payrollsがすべてpersistedでないと実行されない
    cleanup_ad_hoc_revision_mock = Minitest::Mock.new
    handle_ad_hoc_revision_mock = Minitest::Mock.new
  
    context = Minitest::Mock.new

    past_ym = (1..3).map{|i| (Date.new(@ym/100, @ym%100, 1) << i).strftime('%Y%m').to_i}
    past_payrolls = past_ym.map{|ym| Payroll.find_by(ym: @ym, employee_id: @employee8.id)}
    past_payrolls[0].delete
    past_payrolls_with_new_payroll = past_payrolls = past_ym.map{|ym| Payroll.find_by_ym_and_employee_id(@ym, @employee8.id)}
    assert_not past_payrolls_with_new_payroll.all?(&:persisted?)
  
    cleanup_ad_hoc_revision_mock.expect(:call, nil, [context])
    handle_ad_hoc_revision_mock.expect(:call, nil, [context])
  
    @processor.instance_variable_set(:@past_payrolls, past_payrolls_with_new_payroll)
    @processor.instance_variable_set(:@ym, @ym)
    @processor.instance_variable_set(:@context, context)
  
    PayrollNotification::AdHocRevisionCleaner.stub(:call, cleanup_ad_hoc_revision_mock) do
      PayrollNotification::AdHocRevisionHandler.stub(:call, handle_ad_hoc_revision_mock) do
        @processor.process
      end
    end
  
    assert_raises(MockExpectationError) { cleanup_ad_hoc_revision_mock.verify }
    assert_raises(MockExpectationError) { handle_ad_hoc_revision_mock.verify }
  end

  def test_handle_annual_determinationはymが9月の場合のみ実行される
    called_september = false
    PayrollNotification::AnnualDeterminationHandler.stub(:call, ->(context) { called_september = true }) do
      @processor.instance_variable_set(:@ym, 202509)
      @processor.instance_variable_set(:@past_payrolls, [])
      @processor.instance_variable_set(:@context, @context)
      @processor.process
    end

    assert called_september
  
    called_august = false
    PayrollNotification::AnnualDeterminationHandler.stub(:call, ->(context) { called_august = true }) do
      @processor.instance_variable_set(:@ym, 202508)
      @processor.instance_variable_set(:@past_payrolls, [])
      @processor.process
    end

    assert_not called_august
  end

  def test_call内のループ処理は例外が発生しても継続する
    payrolls = [@payroll_created_yesterday, @payroll_updated_yesterday]
    called_ids = []
    processor = PayrollNotification::PayrollNotificationProcessor.new(payrolls.first)
    processor.define_singleton_method(:send) do
      raise 'テスト用の例外'
    end

    PayrollNotification::PayrollNotificationProcessor.stub(:new, ->(payroll) {
      called_ids << payroll.id
      processor
    }) do
      assert_nothing_raised do
        PayrollNotification::PayrollNotificationProcessor.call
      end
        
      assert_equal payrolls.map(&:id).sort, called_ids.sort
    end
  end

  def test_ad_hoc_revision_cleanerの失敗ログを出力する
    @processor.instance_variable_set(:@context, @context)

    expected_message = /随時改定の対応チェックとお知らせ更新失敗：.*payroll_id=#{@payroll_updated_yesterday.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    Rails.stub(:logger, logger_mock) do
      @processor.stub(:cleanup_ad_hoc_revision, -> {processor_mock.call}) do
        @processor.send(:log_failure_with_block, '随時改定の対応チェックとお知らせ更新') do
          @processor.cleanup_ad_hoc_revision
        end
      end
  
      logger_mock.verify
      processor_mock.verify
    end
  end

  def test_ad_hoc_revision_handlerの失敗ログを出力する
    @processor.instance_variable_set(:@context, @context)

    expected_message = /随時改定のお知らせ生成失敗：.*payroll_id=#{@payroll_updated_yesterday.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    Rails.stub(:logger, logger_mock) do
      @processor.stub(:handle_ad_hoc_revision, -> {processor_mock.call}) do
        @processor.send(:log_failure_with_block, '随時改定のお知らせ生成') do
          @processor.handle_ad_hoc_revision
        end
      end
  
      logger_mock.verify
      processor_mock.verify
    end
  end

  def test_annual_determination_handlerの失敗ログを出力する
    @processor.instance_variable_set(:@context, @context)

    expected_message = /定時決定の対応チェックとお知らせ生成失敗：.*payroll_id=#{@payroll_updated_yesterday.id}/
    logger_mock = Minitest::Mock.new
    logger_mock.expect(:error, nil) {|msg| msg.match?(expected_message)}
  
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil) {raise "テスト用の例外"}
  
    Rails.stub(:logger, logger_mock) do
      @processor.stub(:handle_annual_determination, -> {processor_mock.call}) do
        @processor.send(:log_failure_with_block, '定時決定の対応チェックとお知らせ生成') do
          @processor.handle_annual_determination
        end
      end
  
      logger_mock.verify
      processor_mock.verify
    end
  end

end