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

  def test_admin_becoming_inactive_ユーザに紐付かない従業員はfalse
    e = Employee.find(10)
    assert_nil e.user
    e.disabled = true
    assert_not e.admin_becoming_inactive?
  end

  def test_admin_becoming_inactive_管理者ユーザに紐づく従業員が無効になる場合はtrue
    e = admin.employee
    e.disabled = true
    assert e.admin_becoming_inactive?
  end

  def test_管理者ユーザに紐づく従業員が無効化される保存でcompanyのlock_versionが上がる
    company = admin.employee.company
    before_lock_version = company.lock_version

    admin.employee.disabled = true
    admin.employee.save!(validate: false)

    assert_equal before_lock_version + 1, company.reload.lock_version
  end

  def test_同時に最後の2人の管理者ユーザに紐づく従業員を無効化しようとした場合_片方はStaleObjectErrorになり管理者が1人残る
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    request1 = Employee.find(admin.employee.id)
    request2 = Employee.find(other_admin.employee.id)

    request1.company
    request2.company

    request1.disabled = true
    request2.disabled = true
    assert request1.valid?
    assert request2.valid?

    request1.save!

    assert_raises(ActiveRecord::StaleObjectError) do
      request2.save!(validate: false)
    end

    assert Employee.find(admin.employee.id).disabled?
    assert_not Employee.find(other_admin.employee.id).disabled?
  end

  def test_同時に最後の2人の管理者ユーザに紐づく従業員を削除しようとした場合_片方はStaleObjectErrorになり管理者が1人残る
    other_admin = User.find(6)
    other_admin.update!(admin: true)

    request1 = Employee.find(admin.employee.id)
    request2 = Employee.find(other_admin.employee.id)

    request1.company
    request2.company

    request1.deleted = true
    request2.deleted = true
    assert request1.valid?
    assert request2.valid?

    request1.save!

    assert_raises(ActiveRecord::StaleObjectError) do
      request2.save!(validate: false)
    end

    assert Employee.find(admin.employee.id).deleted?
    assert_not Employee.find(other_admin.employee.id).deleted?
  end

end
