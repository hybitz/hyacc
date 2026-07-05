require 'test_helper'

class LastActiveAdminValidatorTest < ActiveSupport::TestCase
  def test_対応外モデルではArgumentError
    error = assert_raises(ArgumentError) do
      Validators::LastActiveAdminValidator.new.validate(Bank.new)
    end
    assert_equal 'LastActiveAdminValidator: Bank は対応外です', error.message
  end

  def test_ログイン可能な管理権限を持つユーザーが1人のとき_ユーザーを削除できない
    assert admin.admin?
    assert admin.active_admin?

    admin.deleted = true
    assert admin.invalid?
    assert_equal ERR_LAST_ACTIVE_ADMIN_DELETE, admin.errors[:base].first
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_ユーザーを削除できる
    other_admin = User.find(6)

    other_admin.update!(admin: true)
    assert admin.admin?
    assert other_admin.admin?

    other_admin.deleted = true
    assert other_admin.valid?
  end

  def test_非adminのユーザーは削除できる
    assert_not user.admin?

    user.deleted = true
    assert user.valid?
  end

  def test_ログイン可能な管理権限を持つユーザーが1人のとき_従業員を無効にできない
    employee = admin.employee

    assert employee.user.admin?
    assert employee.user.active_admin?

    employee.disabled = true
    assert employee.invalid?
    assert_equal ERR_LAST_ACTIVE_ADMIN_DISABLE, employee.errors[:base].first
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_従業員を無効にできる
    other_admin = User.find(6)

    other_admin.update!(admin: true)
    assert admin.admin?
    assert other_admin.admin?

    other_admin.employee.disabled = true
    assert other_admin.employee.valid?
  end

  def test_ログイン可能な管理権限を持つユーザーが1人のとき_従業員を削除できない
    employee = admin.employee

    assert employee.user.admin?
    assert employee.user.active_admin?

    employee.deleted = true
    assert employee.invalid?
    assert_equal ERR_LAST_ACTIVE_ADMIN_DELETE, employee.errors[:base].first
  end

  def test_ログイン可能な管理権限を持つユーザーが2人のとき_従業員を削除できる
    other_admin = User.find(6)

    other_admin.update!(admin: true)
    assert admin.admin?
    assert other_admin.admin?

    other_admin.employee.deleted = true
    assert other_admin.employee.valid?
  end

end
