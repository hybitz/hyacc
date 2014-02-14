# -*- encoding : utf-8 -*-
#
# $Id: service_mock.rb 2887 2012-06-16 16:13:09Z hiro $
# Product: hyacc
# Copyright 2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class HyaccMaster::ServiceMock
    
  def get_prefectures
    prefectures = []
    prefectures << {:id=>1, :name=>'北海道'}
    prefectures
  end

  def get_pension(ym = nil, base_salary = 0)
    pension = Insurance.new
    pension.apply_start_ym = 201201
    pension.apply_end_ym = 201212
    pension.grade = 1
    pension.pay_range_above = 30
    pension.pay_range_under = 20
    pension.monthly_earnings = 25
    pension.welfare_pension_insurance_all = 10000
    pension.welfare_pension_insurance_half = 5000
    pension
  end
  
  def get_insurance(ym = nil, prefecture_id = nil, base_salary = 0)
    insurance = Insurance.new
    insurance.apply_start_ym = 201201
    insurance.apply_end_ym = 201212
    insurance.grade = 1
    insurance.pay_range_above = 30
    insurance.pay_range_under = 20
    insurance.monthly_earnings = 25
    insurance.health_insurance_all = 31160
    insurance.health_insurance_half = 15580
    insurance.health_insurance_all_care = 4000
    insurance.health_insurance_half_care = 2000
    insurance
  end
  
  def get_basic_info(ym = nil, base_salary = 0)
    insurance = Insurance.new
    insurance.grade = 27
    insurance.pay_range_above = 395000
    insurance.pay_range_under = 425000
    insurance.monthly_earnings = 410000
    insurance
  end
end