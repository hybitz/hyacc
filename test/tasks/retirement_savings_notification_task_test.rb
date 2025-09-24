require 'test_helper'
require 'rake'
require 'minitest/mock'

class RetirementSavingsNotificationTaskTest < ActiveSupport::TestCase

  def setup
    Rake.application.rake_require("tasks/retirement_savings_notification")
    Rake::Task.define_task(:environment)
  end

  def test_generate_start_notice
    messages = []
    RetirementSavingsNotification::StartNoticeGenerator.stub(:call, -> {}) do
      HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
        Rake::Task["hyacc:retirement_savings_notification:generate_start_notice"].invoke
      end
    end

    assert messages.any?{|msg| msg == "退職金積立開始のお知らせ生成を開始する"}
    assert messages.any?{|msg| msg == "退職金積立開始のお知らせ生成を終了する"}
  end

  def test_cleanup_start_notice
    messages = []
    RetirementSavingsNotification::StartNoticeCleaner.stub(:call, -> {}) do
      HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
        Rake::Task["hyacc:retirement_savings_notification:cleanup_start_notice"].invoke
      end
    end

    assert messages.any?{|msg| msg == "退職金積立開始のお知らせ削除を開始する"}
    assert messages.any?{|msg| msg == "退職金積立開始のお知らせ削除を終了する"}
  end
end