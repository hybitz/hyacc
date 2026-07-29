require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  def test_qualification_allowance
    assert employee.skills.present?
    assert employee.qualification_allowance > 0
    
    assert executive.skills.present?
    assert executive.qualification_allowance == 0
  end

  def test_age_at
    e = Employee.new
    e.birth = Date.new(2000, 2, 29)
    assert_equal 19, e.age_at(Date.new(2020, 2, 28))
    assert_equal 20, e.age_at(Date.new(2020, 2, 29))
    assert_equal 20, e.age_at(Date.new(2020, 3, 1))
  end

  def test_representative_or_family_type_name
    assert_equal '代表者', Employee.find(10).representative_or_family_type_name
    assert_equal '代表者の家族', Employee.find(6).representative_or_family_type_name
    assert_nil Employee.find(1).representative_or_family_type_name
  end

  def test_user_loginable_ユーザなしはfalse
    e = Employee.new
    assert_not e.user_loginable?
  end

  def test_user_loginable_ログイン可能なユーザがいればtrue
    e = user.employee
    assert e.user_loginable?
    assert e.user.active_for_authentication?
  end

  def test_user_loginable_無効化済み従業員はfalse
    e = users(:disabled_employee_user).employee
    assert_not e.user_loginable?
  end

  def test_admin_becoming_inactive_ユーザーに紐付かない従業員はfalse
    e = Employee.find(10)
    assert_nil e.user
    e.disabled = true
    assert_not e.admin_becoming_inactive?
  end

  def test_admin_becoming_inactive_管理者ユーザーに紐づく従業員が無効になる場合はtrue
    e = admin.employee
    e.disabled = true
    assert e.admin_becoming_inactive?
  end

  def test_管理者ユーザーに紐づく従業員が無効になる場合はcompanyのlock_versionが上がる
    other_admin = User.find(9)
    other_admin.update!(admin: true)

    user = User.find(3)
    assert user.active_admin?
    assert_equal user.employee.company_id, other_admin.employee.company_id

    company = user.employee.company
    before_lock_version = company.lock_version

    user.employee.disabled = true
    user.employee.company_lock_version = before_lock_version
    user.employee.save!

    assert_equal before_lock_version + 1, company.reload.lock_version
  end

  def test_管理者ユーザーに紐づく従業員が削除される場合はcompanyのlock_versionが上がる
    other_admin = User.find(9)
    other_admin.update!(admin: true)

    user = User.find(3)
    assert user.active_admin?
    assert_equal user.employee.company_id, other_admin.employee.company_id

    company = user.employee.company
    before_lock_version = company.lock_version

    user.employee.deleted = true
    user.employee.company_lock_version = before_lock_version
    user.employee.save!

    assert_equal before_lock_version + 1, company.reload.lock_version
  end

  def test_氏名の更新ではcompanyのlock_versionは上がらない
    user = User.find(3)
    company = user.employee.company
    before_lock_version = company.lock_version

    user.employee.last_name = "#{user.employee.last_name}test"
    user.employee.save!

    assert_equal before_lock_version, company.reload.lock_version
  end

  def test_管理者ユーザーに紐づく従業員が無効になる場合はcompany_lock_versionがない場合はエラー
    other_admin = User.find(9)
    other_admin.update!(admin: true)

    user = User.find(3)
    assert user.active_admin?
    assert_equal user.employee.company_id, other_admin.employee.company_id

    user.employee.disabled = true

    e = assert_raises(HyaccException) do
      user.employee.save!
    end
    assert_equal ERR_ILLEGAL_STATE, e.message
  end

end
