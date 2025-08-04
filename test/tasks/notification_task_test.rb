require 'test_helper'
require 'rake'

class NotificationTaskTest < ActiveSupport::TestCase
  def setup
    UserNotification.delete_all
    Notification.delete_all
    @deleted_user = User.last
    @deleted_user.update!(deleted: true)
    @user_count = User.where(deleted: false).size
    Rake.application.rake_require('tasks/notification')
    Rake::Task.define_task(:environment)
    Rake::Task['hyacc:notification:generate'].reenable
    Rake::Task['hyacc:notification:cleanup'].reenable
  end

  def test_generate
    assert_difference 'Notification.where(deleted: false, category: :report_submission).size', 1 do
      assert_difference 'UserNotification.count', @user_count do
        Rake::Task['hyacc:notification:generate'].invoke
      end
    end

    notification = Notification.last
    assert_equal "令和7年の算定基礎届の提出期限は 7月10日 です。", notification.message
    refute_includes notification.user_notifications.pluck(:user_id), @deleted_user.id
  end

  def test_generateを続けて複数回実行しても状態に変化は無い
    assert_difference 'Notification.where(deleted: false, category: :report_submission).size', 1 do
      assert_difference 'UserNotification.count', @user_count do
        Rake::Task['hyacc:notification:generate'].invoke
      end
    end

    Rake::Task['hyacc:notification:generate'].reenable

    assert_no_difference 'Notification.count' do
      assert_no_difference 'Notification.where(deleted: false, category: :report_submission).size' do
        assert_no_difference 'UserNotification.count' do 
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end
  end

  def test_generate実行時に論理削除済みの同一メッセージのお知らせがある場合は論理削除を解除する
    assert_difference 'Notification.where(deleted: false, category: :report_submission).size', 1 do
      assert_difference 'UserNotification.count', @user_count do 
        Rake::Task['hyacc:notification:generate'].invoke
      end
    end

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: true, category: :report_submission).size', 1 do
        assert_no_difference 'UserNotification.count' do
          Rake::Task['hyacc:notification:cleanup'].invoke
        end
      end
    end

    Rake::Task['hyacc:notification:generate'].reenable

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: false, category: :report_submission).size', 1 do
        assert_no_difference 'UserNotification.count' do 
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end
  end

  def test_cleanup
    assert_difference 'Notification.where(deleted: false, category: :report_submission).size', 1 do
      assert_difference 'UserNotification.count', @user_count do
        Rake::Task['hyacc:notification:generate'].invoke
      end
    end

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: true, category: :report_submission).size', 1 do
        assert_no_difference 'UserNotification.count' do
          Rake::Task['hyacc:notification:cleanup'].invoke
        end
      end
    end
  end

  def test_cleanupを続けて複数回実行しても状態に変化は無い
    assert_difference 'Notification.where(deleted: false, category: :report_submission).size', 1 do
      assert_difference 'UserNotification.count', @user_count do
        Rake::Task['hyacc:notification:generate'].invoke
      end
    end

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: true, category: :report_submission).size', 1 do
        assert_no_difference 'UserNotification.count' do
          Rake::Task['hyacc:notification:cleanup'].invoke
        end
      end
    end

    Rake::Task['hyacc:notification:cleanup'].reenable

    assert_no_difference 'Notification.count' do
      assert_no_difference 'Notification.where(deleted: true, category: :report_submission).size' do
        assert_no_difference 'UserNotification.count' do
          Rake::Task['hyacc:notification:cleanup'].invoke
        end
      end
    end
  end

end