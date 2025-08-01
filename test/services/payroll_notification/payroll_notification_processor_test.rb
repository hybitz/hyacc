require 'test_helper'
require 'minitest/mock'

class PayrollNotificationProcessorTest < ActiveSupport::TestCase

  def setup
    @employee8 = Employee.find(8)
    BankAccount.second.update!(company_id: @employee8.company.id, for_payroll: true)
    fy = @employee8.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @ym = 202508
    yesterday = Date.yesterday

    @payroll_updated_yesterday = Payroll.find_by(employee_id: @employee8.id, ym: @ym)
    @payroll_updated_yesterday.update!(updated_at: yesterday.noon)

    @payroll_updated_two_days_ago = Payroll.find_by(employee_id: @employee8.id, ym: 202507)
    @payroll_updated_two_days_ago.update!(updated_at: (Date.today - 2).noon)

    employee1 = Employee.first
    fy = employee1.company.fiscal_years.find_or_initialize_by(fiscal_year: 2025)
    fy.save!
    @payroll_created_yesterday = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee1,
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at: yesterday.noon,
      create_user_id: employee1.user.id,
      update_user_id: employee1.user.id)

    employee2 = Employee.second
    @payroll_created_two_days_ago = Payroll.create!(
      ym: @ym, 
      pay_day: '2025-09-15', 
      employee: employee2, 
      base_salary: 300_000, 
      monthly_standard: 300_000, 
      created_at: (Date.today - 2).noon,
      create_user_id: employee2.user.id,
      update_user_id: employee2.user.id)

      @processor = PayrollNotification::PayrollNotificationProcessor.allocate
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
    assert_not_includes called_ids, @payroll_created_two_days_ago.id
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

end