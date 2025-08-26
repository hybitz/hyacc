require 'test_helper'
require 'rake'
require 'minitest/mock'

class PayrollNotificationTaskTest < ActiveSupport::TestCase

  def setup
    Rake.application.rake_require("tasks/payroll_notification")
    Rake::Task.define_task(:environment)
  end

  def test_handle_and_cleanup_based_on_payroll
    processor_mock = Minitest::Mock.new
    processor_mock.expect(:call, nil)

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil, ["Payrollからお知らせの登録・削除を開始する"])
    logger_mock.expect(:info, nil, ["Payrollからお知らせの登録・削除を終了する"])
  
    PayrollNotification::PayrollNotificationProcessor.stub(:call, -> {processor_mock.call}) do
      HyaccLogger.stub(:info, ->(msg) {logger_mock.info(msg)}) do
        Rake::Task["hyacc:payroll_notification:handle_and_cleanup_based_on_payroll"].invoke
      end
    end

    processor_mock.verify
    logger_mock.verify
  end

end