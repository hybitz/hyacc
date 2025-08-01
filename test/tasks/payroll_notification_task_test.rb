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

    PayrollNotification::PayrollNotificationProcessor.stub(:call, -> { processor_mock.call }) do
      Rake::Task["hyacc:payroll_notification:handle_and_cleanup_based_on_payroll"].invoke
    end

    processor_mock.verify
  end

end