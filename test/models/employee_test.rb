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

end
