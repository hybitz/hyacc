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

  def test_給与振込口座_新規で全部空なら口座を作らない
    e = executive
    assert_nil e.employee_bank_account

    e.employee_bank_account_attributes = {
      bank_id: '', bank_office_id: '', code: ''
    }
    assert_nil e.employee_bank_account
  end

  def test_給与振込口座_既存で不完全なら削除される
    e = employee
    account = e.employee_bank_account
    assert account

    e.employee_bank_account_attributes = {
      id: account.id, bank_id: account.bank_id, bank_office_id: '', code: account.code
    }
    assert e.save
    assert_nil e.reload.employee_bank_account
  end

end
