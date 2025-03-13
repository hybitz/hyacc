require 'test_helper'

class UniqueBranchEmployeesValidatorTest < ActiveSupport::TestCase
  def setup
    @branch_id = employee.branch_employees.first.branch_id
    @new_branch_id = BranchEmployee.where.not(employee_id: employee.id).first.branch_id
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

    employee.errors.delete(:base)
    employee.branch_employees.reload.build(branch_id: @branch_id, default_branch: true)
    assert employee.invalid?
    assert employee.errors[:base].include?(I18n.t('errors.messages.branch_employees_duplicated'))
  end

end