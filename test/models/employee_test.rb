require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  def test_set_company_id
    u = User.new(valid_user_params.merge(:company_id => company.id, :email => 'test@example.com'))
    u.build_employee(:last_name => 'a', :first_name => 'a', :birth => Date.today, :employment_date => Date.today, :sex => SEX_TYPE_M)
    assert u.save, u.errors.full_messages.join("\n")
    assert_equal company.id, u.employee.company_id
  end

end
