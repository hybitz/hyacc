require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  def test_qualification_allowance
    assert employee.skills.present?
    assert employee.qualification_allowance > 0
    
    assert executive.skills.present?
    assert executive.qualification_allowance == 0
  end

end
