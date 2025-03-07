require 'test_helper'

class UniqueBranchEmployeesValidatorTest < ActiveSupport::TestCase

  def test_所属部門の重複チェック
    assert_not employee.branch_employees.where(deleted: false).find{|be| be.branch_id == 2 }.present?
    employee.branch_employees.build(branch_id: 2)
    assert employee.valid?
    assert_difference 'BranchEmployee.count', 1 do
      assert employee.save
    end
    assert employee.errors.empty?

    assert employee.branch_employees.where(deleted: false).find{|be| be.branch_id == branch.id }.present?
    employee.branch_employees.build(branch_id: branch.id, deleted: true)
    assert employee.valid?
    assert_difference 'BranchEmployee.count', 1 do
      assert_no_difference 'BranchEmployee.where(deleted: false).count' do
        assert employee.save
      end
    end
    assert employee.errors.empty?

    employee.branch_employees.build(branch_id: branch.id)
    assert_not employee.valid?
    assert_no_difference 'BranchEmployee.count' do
      assert_not employee.save
    end
    assert employee.errors[:base].include?(I18n.t('errors.messages.branch_employees_duplicated'))
  end

end