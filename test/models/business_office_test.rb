require 'test_helper'

class BusinessOfficeText < ActiveSupport::TestCase

  def test_branches
    bo = company.business_offices.create!(business_office_params)
    b = company.branches.create!(branch_params.merge(business_office: bo))
    b2 = company.branches.create!(branch_params.merge(parent: b))

    assert_equal 2, bo.branches.count
    assert_includes bo.branches, b
    assert_includes bo.branches, b2
  end

  def test_employees
    today = Date.today

    bo = company.business_offices.create!(business_office_params)
    b = company.branches.create!(branch_params.merge(business_office: bo))
    e = company.employees.create!(employee_params.merge(employment_date: today, retirement_date: nil))
    be = b.branch_employees.create!(employee: e, default_branch: false)
    
    assert_equal 0, bo.employees(today).count, '主部門ではない所属はカウントしないこと'
    
    assert be.update(default_branch: true)
    assert_equal 1, bo.employees(today).count, '主部門への所属はカウントすること'
  end

end
