require 'test_helper'
require 'minitest/mock'

class ReportSubmissionNoticeGeneratorTest < ActiveSupport::TestCase
  def test_notificationがあれば処理を中断する
    Notification.first.update!(created_at: Time.current.change(month: 6).beginning_of_month)
    target_period = Time.current.change(month: 6).beginning_of_month...Time.current.change(month: 7).beginning_of_month
    assert Notification.exists?(category: :report_submission, created_at: target_period)

    notification_create_called = false
    user_notification_create_called = false

    Notification.stub(:create!, ->(*) {notification_create_called = true}) do
      UserNotification.stub(:find_or_create_by!, ->(*) {user_notification_create_called = true}) do
        assert_no_difference "Notification.count" do
          PayrollNotification::ReportSubmissionNoticeGenerator.call
        end
      end
    end

    assert_equal false, notification_create_called
    assert_equal false, user_notification_create_called
  end

  def test_notificationを生成しuserと紐づける
    UserNotification.delete_all
    Notification.delete_all

    assert_difference 'Notification.count', 1 do
      PayrollNotification::ReportSubmissionNoticeGenerator.call
    end

    due_date = Date.new(Date.current.year, 7, 10)
    due_date += 1 while !HyaccDateUtil.weekday?(due_date)
    message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"

    notification = Notification.find_by(category: :report_submission, message: message)
    assert_not notification.nil?

    users = User.where(deleted: false)
    assert_equal users.size, UserNotification.where(notification_id: notification.id).size
    
    users.find_each do |user|
      assert UserNotification.exists?(notification_id: notification.id, user_id: user.id)
    end
  end

  def test_notificationの生成とuserとの紐づけの成功ログを出力する
    UserNotification.delete_all
    Notification.delete_all

    due_date = Date.new(Date.current.year, 7, 10)
    due_date += 1 while !HyaccDateUtil.weekday?(due_date)
    message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"

    logger_mock = Minitest::Mock.new
    logger_mock.expect(:info, nil) do |msg|
      msg.include?("お知らせ生成成功") &&
      msg.include?("message=#{message}")
    end

    User.where(deleted: false).each do |user|
      logger_mock.expect(:info, nil) do |msg|
        msg.include?("お知らせ紐づけ成功") &&
        msg.include?("user_id=#{user.id}")
      end
    end

    HyaccLogger.stub(:info, ->(msg) {logger_mock.info(msg)}) do
      PayrollNotification::ReportSubmissionNoticeGenerator.call
    end

    logger_mock.verify
  end

  def test_お知らせ生成を失敗すると処理を中断する
    UserNotification.delete_all
    Notification.delete_all

    logs = []
    called_user_ids = []

    Notification.stub(:create!, ->(*) { raise "お知らせ生成失敗テスト" }) do
      UserNotification.stub(:find_or_create_by!, ->(attrs) {
        called_user_ids << attrs[:user_id]
      }) do
        HyaccLogger.stub(:error, ->(msg) { logs << msg }) do
          assert_nothing_raised do
            PayrollNotification::ReportSubmissionNoticeGenerator.call
          end
        end
      end
    end

    assert logs.any? {|log| log.include?("お知らせ生成失敗: error=お知らせ生成失敗テスト")}
    assert_equal [], called_user_ids
  end

  def test_ループ処理は例外が発生しても継続する
    UserNotification.delete_all
    Notification.delete_all
  
    failing_user = User.where(deleted: false).first
    other_users = User.where(deleted: false).where.not(id: failing_user.id)
  
    called_user_ids = []
    logs = []
  
    UserNotification.stub :find_or_create_by!, ->(attrs) {
      user_id = attrs[:user_id]
      called_user_ids << user_id
      raise "テスト用の例外" if user_id == failing_user.id
      UserNotification.create!(attrs)
    } do
      HyaccLogger.stub(:error, ->(msg) { logs << msg }) do
        assert_nothing_raised do
          PayrollNotification::ReportSubmissionNoticeGenerator.call
        end
      end
    end

    expected_message = "紐づけ失敗: user_id=#{failing_user.id} error=テスト用の例外"
    assert logs.any? {|log| log.include?(expected_message)}

    assert_includes called_user_ids, failing_user.id
    assert_equal User.where(deleted: false).pluck(:id).sort, called_user_ids.sort

    due_date = Date.new(Date.current.year, 7, 10)
    due_date += 1 while !HyaccDateUtil.weekday?(due_date)
    message = "#{TaxJp::Gengou.to_wareki(Date.new(due_date.year.to_i, 12, 31), only_date: false, format: '%y')}年の算定基礎届の提出期限は #{due_date.strftime("%-m月%d日")} です。"
  
    notification = Notification.find_by(category: :report_submission, message: message)
  
    other_users.each do |user|
      assert UserNotification.exists?(user_id: user.id, notification_id: notification.id)
    end
  end
end