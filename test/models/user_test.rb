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

  def test_有効なユーザはログイン可
    assert user.active_for_authentication?
  end

  def test_削除済みユーザはログイン不可
    assert_not users(:deleted_user).active_for_authentication?
  end

  def test_無効化済み従業員に紐づくユーザはログイン不可
    assert_not users(:disabled_employee_user).active_for_authentication?
  end

  def test_削除済み従業員に紐づくユーザはログイン不可
    assert_not users(:deleted_employee_user).active_for_authentication?
  end

  def test_loginable_削除済みユーザはfalse
    assert_not users(:deleted_user).loginable?
  end

  def test_loginable_無効化済み従業員に紐づくユーザはfalse
    assert_not users(:disabled_employee_user).loginable?
  end

  def test_active_admin_無効化済みユーザでadminフラグがtrueでもfalse
    u = users(:disabled_employee_user)
    u.admin = true
    assert_not u.active_admin?
  end

  def test_would_remove_last_active_admin_非adminはfalse
    assert_not user.admin?
    assert_not user.would_remove_last_active_admin?
  end

end
