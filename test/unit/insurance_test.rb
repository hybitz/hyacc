# -*- encoding : utf-8 -*-
#
# $Id: insurance_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class InsuranceTest < ActiveRecord::TestCase
  fixtures :insurances
  
  def setup
    @insurance = Insurance.find(103)
  end
  
  def test_create
    assert_kind_of Insurance, @insurance
    fix_insurance = insurances(:insurance_00103)
    assert_equal fix_insurance["id"], @insurance.id
    assert_equal fix_insurance["apply_start_ym"], @insurance.apply_start_ym
    assert_equal fix_insurance["apply_end_ym"], @insurance.apply_end_ym
    assert_equal fix_insurance["pay_range_above"], @insurance.pay_range_above
    assert_equal fix_insurance["pay_range_under"], @insurance.pay_range_under
    assert_equal fix_insurance["monthly_earnings"], @insurance.monthly_earnings
    assert_equal fix_insurance["daily_earnings"], @insurance.daily_earnings
    assert_equal fix_insurance["health_insurance_all"], @insurance.health_insurance_all
    assert_equal fix_insurance["health_insurance_half"], @insurance.health_insurance_half
    assert_equal fix_insurance["health_insurance_all_care"], @insurance.health_insurance_all_care
    assert_equal fix_insurance["health_insurance_half_care"], @insurance.health_insurance_half_care
    assert_equal fix_insurance["welfare_pension_insurance_all"], @insurance.welfare_pension_insurance_all
    assert_equal fix_insurance["welfare_pension_insurance_half"], @insurance.welfare_pension_insurance_half

  end
end
