require 'test_helper'
require 'rake'

class NotificationTaskTest < ActiveSupport::TestCase
  def setup
    Notification.destroy_all
    @deleted_user = User.last
    @deleted_user.update!(deleted: true)
    @user_count = User.where(deleted: false).count
    Rake.application.rake_require('tasks/notification')
    Rake::Task.define_task(:environment)
    Rake::Task['hyacc:notification:generate'].reenable
  end

  def test_generate
    assert_difference 'Notification.count', 1 do
      assert_difference 'UserNotification.count', @user_count do
        Rake::Task['hyacc:notification:generate'].invoke
      end
    end

    notification = Notification.last
    assert_equal "令和7年の算定基礎届の提出期限は 7月10日 です。", notification.message
    refute_includes notification.users.pluck(:id), @deleted_user.id
  end

  def test_cleanup
    Rake::Task['hyacc:notification:generate'].invoke

    assert_equal 1, Notification.count
    assert_equal @user_count, UserNotification.count

    Rake::Task['hyacc:notification:cleanup'].invoke
    assert_not Notification.exists?
    assert_not UserNotification.exists?
  end

end