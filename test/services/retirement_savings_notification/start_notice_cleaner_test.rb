require 'test_helper'
require 'minitest/mock'

class StartNoticeCleanerTest < ActiveSupport::TestCase
  def setup
    @target_month = Time.current.prev_month(2)
    start_date   = @target_month.beginning_of_month
    @notification = Notification.first
    @notification.update!(category: :retirement_savings, created_at: start_date, deleted: false)
  end

  def test_cleanup_task_deletes_notification_created_within_target_period
    assert_changes '@notification.reload.deleted' do
      RetirementSavingsNotification::StartNoticeCleaner.call
    end

    assert @notification.reload.deleted?
  end

  def test_cleanup_task_skips_notification_created_outside_target_period
    end_date = @target_month.next_month.beginning_of_month
    @notification.update!(created_at: end_date)

    assert_no_changes '@notification.reload.deleted' do
      RetirementSavingsNotification::StartNoticeCleaner.call
    end

    assert_not @notification.reload.deleted?
  end

  def test_logs_message_on_successful_notification_cleanup
    message = nil
    HyaccLogger.stub(:info, ->(msg) {message = msg}) do
      RetirementSavingsNotification::StartNoticeCleaner.call
    end

    assert message == "退職金積立開始のお知らせ削除成功：notification_id=#{@notification.id}"
  end

  def test_logs_message_on_failed_notification_cleanup
    message = nil
    @notification.stub(:update!, ->(*) {raise "テスト用例外"}) do
      scope = [@notification]

      where_mock = Struct.new(:scope).new(scope)
      def where_mock.where(_)
        self
      end

      def where_mock.find_each
        scope.each {|n| yield n}
      end

      HyaccLogger.stub(:error, ->(msg) {message = msg}) do
        Notification.stub(:where, where_mock) do 
          RetirementSavingsNotification::StartNoticeCleaner.call
        end
      end
    end

    assert message == "退職金積立開始のお知らせ削除失敗：notification_id=#{@notification.id}, error=テスト用例外"
  end

  def test_loop_continues_after_exception
    messages = []
    error_notification = @notification.dup
    error_notification.save!

    assert_not @notification.deleted?

    error_notification.stub(:update!, ->(*) {raise "テスト用例外"}) do
      scope = [error_notification, @notification]
      where_mock = Struct.new(:scope).new(scope)

      def where_mock.where(*)
        self
      end

      def where_mock.find_each
        scope.each {|n| yield n}
      end

      HyaccLogger.stub(:error, ->(msg) {messages << msg}) do
        HyaccLogger.stub(:info, ->(msg) {messages << msg}) do
          Notification.stub(:where, where_mock) do
            RetirementSavingsNotification::StartNoticeCleaner.call
          end
        end
      end
    end

    assert messages.any?{|msg| msg == "退職金積立開始のお知らせ削除失敗：notification_id=#{error_notification.id}, error=テスト用例外"}
    assert messages.any?{|msg| msg == "退職金積立開始のお知らせ削除成功：notification_id=#{@notification.id}"}
  end
end