class TaxUtils

  def self.get_insurances(prefecture_code, ym, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')

    ret = []
    TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, prefecture_code).each do |si|
      insurances << convert_tax_jp(si)
    end
    ret
  end

  def self.get_insurance(ym, prefecture_code, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    convert_tax_jp(si)
  end

  # 標準報酬の基本情報を取得
  def self.get_basic_info(ym, prefecture_code, base_salary)
    raise '年月が未指定です。' unless ym

    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    convert_tax_jp(si)
  end

  def self.convert_tax_jp(si)
    ret = Insurance.new
    ret.apply_start_ym = si.valid_from
    ret.apply_end_ym = si.valid_until

    ret.grade = si.grade.grade
    ret.pension_grade = si.grade.pension_grade
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
  private_class_method :convert_tax_jp

  def self.get_employment_insurances
    ret = []
    TaxJp::LaborInsurances::EmploymentInsurance.find_all.each do |ei|
      ret << ei
    end
    ret
  end

  def self.get_employment_insurance(ym)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    TaxJp::LaborInsurances::EmploymentInsurance.find_by_date(date)
  end

end