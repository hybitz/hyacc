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
  
end
