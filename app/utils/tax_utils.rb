class TaxUtils

  def self.get_social_insurances(prefecture_code, ym, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')

    ret = []
    TaxJp::SocialInsurance.find_all_by_date_and_prefecture(date, prefecture_code).each do |si|
      ret << convert_tax_jp_si(si)
    end
    ret
  end

  def self.get_social_insurance(ym, prefecture_code, base_salary)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    convert_tax_jp_si(si)
  end

  def self.get_health_insurance(ym, prefecture_code)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    hi = TaxJp::SocialInsurance.find_health_insurance_by_date_and_prefecture(date, prefecture_code)
    convert_tax_jp_hi(hi)
  end

  def self.get_welfare_pension(ym)
    date = Date.strptime("#{ym}01", '%Y%m%d')
    wp = TaxJp::SocialInsurance.find_welfare_pension_by_date(date)
    convert_tax_jp_wp(wp)
  end

  # 標準報酬の基本情報を取得
  def self.get_basic_info(ym, prefecture_code, base_salary)
    raise '年月が未指定です。' unless ym

    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    convert_tax_jp_si(si)
  end

  def self.get_employment_insurance(ym)
    # 対象月の末日を基準
    date = Date.new(ym.to_i/100, ym.to_i%100, -1)

    TaxJp::LaborInsurances::EmploymentInsurance.find_by_date(date)
  end

  def self.convert_tax_jp_si(si)
    ret = Insurance.new
    ret.valid_from = si.valid_from
    ret.valid_until = si.valid_until

    ret.grade = si.grade.grade
    ret.pension_grade = si.grade.pension_grade
    ret.salary_from = si.grade.salary_from
    ret.salary_to = si.grade.salary_to
    ret.monthly_standard = si.grade.monthly_standard
    ret.daily_standard = si.grade.daily_standard
    
    convert_tax_jp_hi(si.health_insurance, ret)
    convert_tax_jp_wp(si.welfare_pension, ret)

    ret
  end
  private_class_method :convert_tax_jp_si

  def self.convert_tax_jp_hi(hi, to = nil)
    to ||= Insurance.new
    to.health_insurance_all = hi.general_amount
    to.health_insurance_half = hi.general_amount_half
    to.health_insurance_all_care = hi.general_amount_care
    to.health_insurance_half_care = hi.general_amount_care_half
    to
  end
  private_class_method :convert_tax_jp_hi

  def self.convert_tax_jp_wp(wp, to = nil)
    to ||= Insurance.new
    to.welfare_pension_insurance_all = wp.general_amount
    to.welfare_pension_insurance_half = wp.general_amount_half
    to.welfare_pension2_insurance_all = wp.particular_amount
    to.welfare_pension2_insurance_half = wp.particular_amount_half
    to
  end
  private_class_method :convert_tax_jp_wp

end