require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_ログインIDは必須、ユニーク
    user = User.new(user_params)
    assert user.valid?, user.errors.full_messages.join("\n")
    
    user.login_id = ''
    assert user.invalid?
    assert user.errors[:login_id].any?

    user.login_id = admin.login_id
    assert user.invalid?
    assert user.errors[:login_id].any?

    user.login_id = "test.#{time_string}"
    assert user.valid?
    assert user.errors.empty?
  end

  def test_mark_user_notifications_as_deleted
    user = User.where(deleted: false).first
    assert user.user_notifications.where(deleted: false).size > 0

    user.update!(deleted: true)
    assert_empty user.user_notifications.where(deleted: false)
  end
  
end
