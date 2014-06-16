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
    ret = Insurance.new

    case ym.to_i
    when 200811
      ret.apply_start_ym = 200809
      ret.apply_end_ym = 200902
      ret.grade = 26
      ret.pay_range_above = 370000
      ret.pay_range_under = 395000
      ret.monthly_earnings = 380000
      ret.health_insurance_all = 31160
      ret.health_insurance_half = 15580
      ret.health_insurance_all_care = 35454.0
      ret.health_insurance_half_care = 17727.0
    else
      ret.apply_start_ym = 201201
      ret.apply_end_ym = 201212
      ret.grade = 1
      ret.pay_range_above = 30
      ret.pay_range_under = 20
      ret.monthly_earnings = 25
      ret.health_insurance_all = 31160
      ret.health_insurance_half = 15580
      ret.health_insurance_all_care = 4000
      ret.health_insurance_half_care = 2000
    end

    ret
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