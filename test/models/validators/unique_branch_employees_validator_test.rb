require 'test_helper'

class UniqueBranchEmployeesValidatorTest < ActiveSupport::TestCase
  def setup
    @branch_id = employee.branch_employees.first.branch_id
    @new_branch_id = BranchEmployee.where.not(employee_id: employee.id).first.branch_id
    @user = User.new(login_id: 'zero', password: 'zerozero', email: 'test@example.com')
    @user.build_employee(company_id: 1, last_name: 'test_create', first_name: 'a', employment_date: '2009-01-01', sex: 'M', birth: '2000-01-01', my_number: '123456789012')
  end

  def test_所属部門の重複チェック
    employee.branch_employees.build(branch_id: @new_branch_id)
    assert employee.valid?
    assert_difference 'BranchEmployee.count', 1 do
      assert employee.save
    end
    assert employee.errors.empty?

    employee.branch_employees.build(branch_id: @branch_id, deleted: true)
    assert employee.valid?
    assert_difference 'BranchEmployee.count', 1 do
      assert_no_difference 'BranchEmployee.where(deleted: false).count' do
        assert employee.save
      end
    end
    assert employee.errors.empty?

    employee.branch_employees.build(branch_id: @branch_id)
    assert employee.invalid?
    assert employee.errors[:base].include?(I18n.t('errors.messages.branch_employees_duplicated'))
  end

  def test_所属部門のデフォルト設定の重複チェック
    assert employee.branch_employees.find_by(branch_id: @branch_id).default_branch?
    employee.branch_employees.build(branch_id: @branch_id, default_branch: true, deleted: true)
    assert employee.valid?
    assert_difference 'BranchEmployee.count', 1 do
      assert_no_difference 'BranchEmployee.where(deleted: false).count' do
        assert employee.save
      end
    end
    assert employee.errors.empty?

    employee.branch_employees.build(branch_id: @new_branch_id, default_branch: true)
    assert employee.invalid?
    assert employee.errors[:base].include?(I18n.t('errors.messages.default_branches_duplicated'))
  end


  def test_ユーザと従業員を新規に同時登録する時の所属部門の重複チェック
    @user.employee.branch_employees.build(branch_id: @branch_id, default_branch: true, deleted: false)
    @user.employee.branch_employees.build(branch_id: @branch_id, default_branch: false, deleted: false)
    assert @user.invalid?
    assert @user.errors[:base].include?(I18n.t('errors.messages.branch_employees_duplicated'))

    @user.employee.branch_employees.destroy_all
    @user.employee.branch_employees.build(branch_id: @branch_id, default_branch: true, deleted: false)
    @user.employee.branch_employees.build(branch_id: @branch_id, default_branch: false, deleted: true)
    assert @user.valid?
  end

  def test_ユーザと従業員を新規に同時登録する時の所属部門のデフォルト設定の重複チェック
    @user.employee.branch_employees.build(branch_id: @branch_id, default_branch: true, deleted: false)
    @user.employee.branch_employees.build(branch_id: @new_branch_id, default_branch: true, deleted: false)
    assert @user.invalid?
    assert @user.errors[:base].include?(I18n.t('errors.messages.default_branches_duplicated'))

    @user.employee.branch_employees.destroy_all
    @user.employee.branch_employees.build(branch_id: @branch_id, default_branch: true, deleted: false)
    @user.employee.branch_employees.build(branch_id: @new_branch_id, default_branch: true, deleted: true)
    assert @user.valid?
  end

end