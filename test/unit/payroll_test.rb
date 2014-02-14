# -*- encoding : utf-8 -*-
#
# $Id: payroll_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class PayrollTest < ActiveRecord::TestCase
  
  def setup
    @payroll = Payroll.find(45)
  end
  
  def test_create
    assert_kind_of Payroll, @payroll
    fix_payroll = payrolls(:payroll_00045)
    assert_equal fix_payroll["ym"], @payroll.ym
    assert_equal fix_payroll["employee_id"], @payroll.employee_id
    assert_equal fix_payroll["payroll_journal_header_id"], @payroll.payroll_journal_header_id
    assert_equal fix_payroll["pay_journal_header_id"], @payroll.pay_journal_header_id
    assert_equal fix_payroll["days_of_work"], @payroll.days_of_work
    assert_equal fix_payroll["hours_of_work"], @payroll.hours_of_work
    assert_equal fix_payroll["hours_of_day_off_work"], @payroll.hours_of_day_off_work
    assert_equal fix_payroll["hours_of_early_for_work"], @payroll.hours_of_early_for_work
    assert_equal fix_payroll["hours_of_late_night_work"], @payroll.hours_of_late_night_work
  end
end
