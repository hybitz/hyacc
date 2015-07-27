class HyaccMaster::TaxJp

  def get_insurances(prefecture_code, ym, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')

    insurances = []
    TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, prefecture_code).each do |si|
      insurances << convert_tax_jp(si, :as => 'insurance')
    end
    insurances
  end

  def get_pensions(prefecture_code, ym, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')

    pensions = []
    TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, prefecture_code).each do |si|
      next unless si.grade.pension_grade > 0
      break if pensions.last and si.grade.pension_grade == pensions.last.grade
      pensions << convert_tax_jp(si, :as => 'pension')
    end
    pensions
  end

  def get_pension(ym, prefecture_code, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    pension = convert_tax_jp(si, :as => 'pension')
  end

  def get_insurance(ym, prefecture_code, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    insurance = convert_tax_jp(si, :as => 'insurance')
  end
  
  #標準報酬の基本情報を取得
  def get_basic_info(ym, prefecture_code, base_salary)
    raise '年月が未指定です。' unless ym

    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    insurance = convert_tax_jp(si, :as => 'grade')
  end

  private

  def convert_tax_jp(si, options = {})
    ret = Insurance.new

    case options[:as]
    when 'grade'
      ret.grade = si.grade.grade
      ret.pension_grade = si.grade.pension_grade
      ret.apply_start_ym = si.grade.valid_from
      ret.apply_end_ym = si.grade.valid_until
    when 'insurance'
      ret.grade = si.grade.grade
      ret.pension_grade = si.grade.pension_grade
      ret.apply_start_ym = si.health_insurance.valid_from
      ret.apply_end_ym = si.health_insurance.valid_until
    when 'pension'
      ret.grade = si.grade.pension_grade
      ret.apply_start_ym = si.welfare_pension.valid_from
      ret.apply_end_ym = si.welfare_pension.valid_until
    end

    ret.pay_range_above = si.grade.salary_from
    ret.pay_range_under = si.grade.salary_to
    ret.monthly_earnings = si.grade.monthly_standard
    ret.daily_earnings = si.grade.daily_standard
    ret.health_insurance_all = si.health_insurance.general_amount
    ret.health_insurance_half = si.health_insurance.general_amount_half
    ret.health_insurance_all_care = si.health_insurance.general_amount_care
    ret.health_insurance_half_care = si.health_insurance.general_amount_care_half
    ret.welfare_pension_insurance_all = si.welfare_pension.general_amount
    ret.welfare_pension_insurance_half = si.welfare_pension.general_amount_half
    ret.welfare_pension2_insurance_all = si.welfare_pension.particular_amount
    ret.welfare_pension2_insurance_half = si.welfare_pension.particular_amount_half
    ret
  end

end