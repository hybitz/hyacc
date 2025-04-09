require 'test_helper'

class DefaultBranchPresenceValidatorTest < ActiveSupport::TestCase
  def test_ユーザと従業員を同時登録する時にデフォルトの所属部門の存在をチェックする
    user = User.new(login_id: 'zero', password: 'zerozero', email: 'test@example.com')
    user.build_employee(company_id: 1, last_name: 'test_create', first_name: 'a', employment_date: '2009-01-01', sex: 'M', birth: '2000-01-01', my_number: '123456789012')
    assert user.invalid?
    assert user.errors[:base].include?(I18n.t('errors.messages.default_branch_required'))

    user.employee.branch_employees.build(branch_id: 1, default_branch: false)
    user.employee.branch_employees.build(branch_id: 2, default_branch: false)
    assert user.invalid?
    assert user.errors[:base].include?(I18n.t('errors.messages.default_branch_required'))

    user.employee.branch_employees.destroy_all
    user.employee.branch_employees.build(branch_id: 1, default_branch: true, deleted: true)
    user.employee.branch_employees.build(branch_id: 2, default_branch: false)
    assert user.invalid?
    assert user.errors[:base].include?(I18n.t('errors.messages.default_branch_required'))
    
    user.employee.branch_employees.destroy_all
    user.employee.branch_employees.build(branch_id: 1, default_branch: true, deleted: true)
    user.employee.branch_employees.build(branch_id: 1, default_branch: true)
    user.employee.branch_employees.build(branch_id: 2, default_branch: false)
    assert user.valid?
  end

  def test_登録済みのユーザと従業員を編集する時にデフォルトの所属部門の存在をチェックする
    user = User.new(login_id: 'zero', password: 'zerozero', email: 'test@example.com')
    user.build_employee(company_id: 1, last_name: 'test_create', first_name: 'a', employment_date: '2009-01-01', sex: 'M', birth: '2000-01-01', my_number: '123456789012')
    user.employee.branch_employees.build(branch_id: 1, default_branch: true, deleted: false)
    user.employee.branch_employees.build(branch_id: 2, default_branch: false, deleted: false)
    assert user.save!

    employee = user.employee
    employee.branch_employees.first.default_branch = false
    assert employee.invalid?
    assert employee.errors[:base].include?(I18n.t('errors.messages.default_branch_required'))

    employee.reload
    employee.branch_employees.build(branch_id: 1, default_branch: true, deleted: true)
    assert employee.valid?
  end

  def test_ユーザに紐かない従業員の新規作成と編集時にはデフォルトの所属部門の存在をチェックしない
    employee = Employee.new(company_id: 1, last_name: 'test_create', first_name: 'a', employment_date: '2009-01-01', sex: 'M', birth: '2000-01-01', my_number: '123456789012')
    assert employee.save!
    
    employee.last_name = 'test_edit'
    assert employee.save!
  end
end