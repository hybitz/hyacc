require 'test_helper'
require 'minitest/mock'

class ReportSubmissionNoticeCleanerTest < ActiveSupport::TestCase

  def test_notificationがない場合でもエラーは起きない
    UserNotification.delete_all
    Notification.delete_all

    assert_nothing_raised do
      assert_no_difference "Notification.count" do
        PayrollNotification::ReportSubmissionNoticeCleaner.call
      end
    end
  end

  def test_notificationのdeletedフラグがtrueの場合は処理を中断する
    create_time = Time.current.change(month: 6).beginning_of_month
    notification = Notification.first
    notification.update!(created_at: create_time, deleted: true)

    notification_update_called = false
    Notification.stub(:find_by, notification) do
      notification.stub(:update!, ->(*) {notification_update_called = true}) do
        assert_no_changes "notification.reload.deleted" do
          PayrollNotification::ReportSubmissionNoticeCleaner.call
        end
      end
    end

    assert_equal false, notification_update_called
  end

  def test_notificationのdeletedフラグがfalseの場合はtrueに更新する
    create_time = Time.current.change(month: 6).beginning_of_month
    notification = Notification.first
    notification.update!(created_at: create_time, deleted: false)

    assert_changes "notification.reload.deleted" do
      PayrollNotification::ReportSubmissionNoticeCleaner.call
    end

    assert notification.deleted?
  end

  def test_更新に成功した場合は成功ログを出力する
    create_time = Time.current.change(month: 6).beginning_of_month
    notification = Notification.first
    notification.update!(created_at: create_time, deleted: false)

    message = nil
    HyaccLogger.stub(:info, ->(msg) {message = msg}) do
      PayrollNotification::ReportSubmissionNoticeCleaner.call
    end
  
    assert_equal "お知らせ削除成功: notification_id=#{notification.id}", message
  end

  def test_更新に失敗した場合は失敗ログを出力する
    create_time = Time.current.change(month: 6).beginning_of_month
    notification = Notification.first
    notification.update!(created_at: create_time, deleted: false)

    message = nil
    Notification.stub(:find_by, notification) do
      notification.stub(:update!, ->(*) { raise "お知らせ削除失敗テスト"}) do
        HyaccLogger.stub(:error, ->(msg) {message = msg}) do
          PayrollNotification::ReportSubmissionNoticeCleaner.call
        end
      end
    end

    assert_equal "お知らせ削除失敗: error=お知らせ削除失敗テスト", message
  end
end