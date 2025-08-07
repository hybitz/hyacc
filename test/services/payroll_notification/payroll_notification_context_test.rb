require 'test_helper'

class PayrollNotificationContextTest < ActiveSupport::TestCase

  def test_build_context
    employee = Employee.find(8)
    ym = 202508
    payroll = Payroll.find_or_initialize_regular_payroll(ym, employee.id)
    past_ym = (1..3).map{|i| (Date.new(ym/100, ym%100, 1) << i).strftime('%Y%m').to_i}
    past_payrolls = past_ym.map{|ym| Payroll.find_or_initialize_regular_payroll(ym, employee.id)}    
    
    assert_equal 202508, ym
    assert_equal [202507, 202506, 202505], past_ym
    assert_equal 3, past_payrolls.size
    
    context = PayrollNotification::PayrollNotificationContext.new(
      payroll: payroll,
      ym: payroll.ym,
      employee: employee,
      past_ym: past_ym,
      past_payrolls: past_payrolls)
      
    assert_equal payroll, context.payroll
    assert_equal ym, context.ym
    assert_equal past_ym, context.past_ym
    assert_equal past_payrolls, context.past_payrolls
  end

end
