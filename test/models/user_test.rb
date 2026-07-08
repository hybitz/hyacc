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

  def test_active_admin_無効化済みユーザでadminフラグがtrueでもfalse
    u = users(:disabled_employee_user)
    u.admin = true
    assert_not u.active_admin?
  end

  def test_would_remove_last_active_admin_非adminはfalse
    assert_not user.admin?
    assert_not user.would_remove_last_active_admin?
  end

  def test_admin_becoming_inactive_非adminの変更はfalse
    assert_not user.admin?
    user.deleted = true
    assert_not user.admin_becoming_inactive?
  end

  def test_admin_becoming_inactive_管理者が無効になる場合はtrue
    admin.deleted = true
    assert admin.admin_becoming_inactive?
  end

  def test_管理者が無効化される保存でcompanyのlock_versionが上がる
    company = admin.employee.company
    before_lock_version = company.lock_version

    admin.admin = false
    admin.save!(validate: false)

    assert_equal before_lock_version + 1, company.reload.lock_version
  end

  def test_管理者が無効化されない保存ではcompanyのlock_versionは上がらない
    company = admin.employee.company
    before_lock_version = company.lock_version

    admin.slips_per_page = admin.slips_per_page + 1
    admin.save!

    assert_equal before_lock_version, company.reload.lock_version
  end

  def test_同時に最後の2人の管理者を無効化しようとした場合_片方はStaleObjectErrorになり管理者が1人残る
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    request1 = User.find(admin.id)
    request2 = User.find(other_admin.id)

    request1.employee.company
    request2.employee.company

    request1.admin = false
    request2.admin = false
    assert request1.valid?
    assert request2.valid?

    request1.save!

    assert_raises(ActiveRecord::StaleObjectError) do
      request2.save!(validate: false)
    end

    assert_not User.find(admin.id).admin?
    assert User.find(other_admin.id).admin?
  end

  def test_同時に最後の2人の管理者を削除しようとした場合_片方はStaleObjectErrorになり管理者が1人残る
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    request1 = User.find(admin.id)
    request2 = User.find(other_admin.id)

    request1.employee.company
    request2.employee.company

    request1.deleted = true
    request2.deleted = true
    assert request1.valid?
    assert request2.valid?

    request1.save!

    assert_raises(ActiveRecord::StaleObjectError) do
      request2.save!(validate: false)
    end

    assert User.find(admin.id).deleted?
    assert_not User.find(other_admin.id).deleted?
  end

end
