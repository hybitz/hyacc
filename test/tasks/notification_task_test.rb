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
    assert_difference 'Notification.where(deleted: false).size', 1 do
      assert_difference 'UserNotification.where(deleted: false).size', @user_count do
        assert_difference 'UserNotification.where(visible: true).size', @user_count do 
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end

    notification = Notification.last
    assert_equal "令和7年の算定基礎届の提出期限は 7月10日 です。", notification.message
    refute_includes notification.users.pluck(:id), @deleted_user.id
  end

  def test_generateを続けて複数回実行しても状態に変化は無い
    assert_difference 'Notification.where(deleted: false).size', 1 do
      assert_difference 'UserNotification.where(deleted: false).size', @user_count do
        assert_difference 'UserNotification.where(visible: true).size', @user_count do 
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end

    Rake::Task['hyacc:notification:generate'].reenable

    assert_no_difference 'Notification.count' do
      assert_no_difference 'Notification.where(deleted: false).size' do
        assert_no_difference 'UserNotification.where(deleted: false).size' do
          assert_no_difference 'UserNotification.where(visible: true).size' do 
            Rake::Task['hyacc:notification:generate'].invoke
          end
        end
      end
    end
  end


  def test_generate実行時に論理削除済みの同一メッセージのお知らせがある場合は論理削除を解除する
    assert_difference 'Notification.where(deleted: false).size', 1 do
      assert_difference 'UserNotification.where(deleted: false).size', @user_count do
        assert_difference 'UserNotification.where(visible: true).size', @user_count do 
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: true).size', 1 do
        assert_difference 'UserNotification.where(deleted: true).size', @user_count do
          assert_difference 'UserNotification.where(visible: false).size', @user_count do
            Rake::Task['hyacc:notification:cleanup'].invoke
          end
        end
      end
    end

    Rake::Task['hyacc:notification:generate'].reenable
    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: false).size', 1 do
        assert_difference 'UserNotification.where(deleted: false).size', @user_count do
          assert_difference 'UserNotification.where(visible: true).size', @user_count do 
            Rake::Task['hyacc:notification:generate'].invoke
          end
        end
      end
    end
  end

  def test_cleanup
    assert_difference 'Notification.where(deleted: false).size', 1 do
      assert_difference 'UserNotification.where(deleted: false).size', @user_count do
        assert_difference 'UserNotification.where(visible: true).size', @user_count do
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: true).size', 1 do
        assert_difference 'UserNotification.where(deleted: true).size', @user_count do
          assert_difference 'UserNotification.where(visible: false).size', @user_count do
            Rake::Task['hyacc:notification:cleanup'].invoke
          end
        end
      end
    end
  end

  def test_cleanupを続けて複数回実行しても状態に変化は無い
    assert_difference 'Notification.where(deleted: false).size', 1 do
      assert_difference 'UserNotification.where(deleted: false).size', @user_count do
        assert_difference 'UserNotification.where(visible: true).size', @user_count do 
          Rake::Task['hyacc:notification:generate'].invoke
        end
      end
    end

    assert_no_difference 'Notification.count' do
      assert_difference 'Notification.where(deleted: true).size', 1 do
        assert_difference 'UserNotification.where(deleted: true).size', @user_count do
          assert_difference 'UserNotification.where(visible: false).size', @user_count do
            Rake::Task['hyacc:notification:cleanup'].invoke
          end
        end
      end
    end

    Rake::Task['hyacc:notification:cleanup'].reenable

    assert_no_difference 'Notification.count' do
      assert_no_difference 'Notification.where(deleted: true).size' do
        assert_no_difference 'UserNotification.where(deleted: true).size', @user_count do
          assert_no_difference 'UserNotification.where(visible: false).size', @user_count do
            Rake::Task['hyacc:notification:cleanup'].invoke
          end
        end
      end
    end
  end

end