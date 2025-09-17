require 'test_helper'
require 'rake'
require 'minitest/mock'

class PayrollNotificationTaskTest < ActiveSupport::TestCase

  def setup
    Rake.application.rake_require("tasks/payroll_notification")
    Rake::Task.define_task(:environment)
  end

  def test_handle_and_cleanup_based_on_payroll
    messages = []
    PayrollNotification::PayrollNotificationProcessor.stub(:call, -> {}) do
      HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
        Rake::Task["hyacc:payroll_notification:handle_and_cleanup_based_on_payroll"].invoke
      end
    end

    assert messages.any?{|msg| msg == "Payrollからお知らせの登録・削除を開始する"}
    assert messages.any?{|msg| msg == "Payrollからお知らせの登録・削除を終了する"}
  end

  def test_generate_report_submission_notice
    messages = []
    PayrollNotification::ReportSubmissionNoticeGenerator.stub(:call, -> {}) do
      HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
        Rake::Task["hyacc:payroll_notification:generate_report_submission_notice"].invoke
      end
    end

    assert messages.any?{|msg| msg == "算定基礎届提出期限のお知らせ生成を開始する"}
    assert messages.any?{|msg| msg == "算定基礎届提出期限のお知らせ生成を終了する"}
  end

  def test_cleanup_report_submission_notice
    messages = []
    PayrollNotification::ReportSubmissionNoticeCleaner.stub(:call, -> {}) do
      HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
        Rake::Task["hyacc:payroll_notification:cleanup_report_submission_notice"].invoke
      end
    end

    assert messages.any?{|msg| msg == "算定基礎届提出期限のお知らせ削除を開始する"}
    assert messages.any?{|msg| msg == "算定基礎届提出期限のお知らせ削除を終了する"}
  end
end