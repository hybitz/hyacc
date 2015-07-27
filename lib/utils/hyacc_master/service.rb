class HyaccMaster::Service

  # HyaccマスタのURL
  HYACC_MASTER_URL = "http://hyacc-master.hybitz.co.jp"

  def get_insurances(prefecture_code, ym, base_salary)
    insurances = []

    response = http.get('/user/insurance/list', :prefectureId => prefecture_code.to_i, :ym => ym, :baseSalary => base_salary)
    ActiveSupport::JSON.decode(response).each do |j|
      ins = Insurance.new
      ins.apply_start_ym = j['startYm'].to_i
      ins.apply_end_ym = j['endYm'].to_i
      ins.grade = j['grade'].to_i
      ins.pay_range_above = j['startSalary'].to_i
      ins.pay_range_under = j['endSalary'].to_i
      ins.monthly_earnings = j['baseSalary'].to_i
      ins.health_insurance_all = j['insurance'].to_f
      ins.health_insurance_half = j['insuranceHalf'].to_f
      ins.health_insurance_all_care = j['insurance2'].to_f
      ins.health_insurance_half_care = j['insurance2Half'].to_f
      insurances << ins
    end
    
    insurances
  end

  def get_pensions(prefecture_code, ym, base_salary)
    pensions = []

    response = http.get('/user/pension/list', :ym => ym, :baseSalary => base_salary)
    ActiveSupport::JSON.decode(response).each do |j|
      p = Pension.new
      p.apply_start_ym = j['startYm'].to_i
      p.apply_end_ym = j['endYm'].to_i
      p.grade = j['grade'].to_i
      p.pay_range_above = j['startSalary'].to_i
      p.pay_range_under = j['endSalary'].to_i
      p.monthly_earnings = j['baseSalary'].to_i
      p.pension = j['pension'].to_i
      p.pension_half = j['pensionHalf'].to_i
      p.pension2 = j['pension2'].to_i
      p.pension2_half = j['pension2Half'].to_i
      pensions << p
    end
    
    pensions
  end

  def get_pension(ym, prefecture_code, base_salary)
    response = http.get('/user/pension/show', :ym => ym, :baseSalary => base_salary)
    json = ActiveSupport::JSON.decode(response)

    pension = Insurance.new
    pension.apply_start_ym = json['startYm'].to_i
    pension.apply_end_ym = json['endYm'].to_i
    pension.grade = json['grade'].to_i
    pension.pay_range_above = json['startSalary'].to_i
    pension.pay_range_under = json['endSalary'].to_i
    pension.monthly_earnings = json['baseSalary'].to_i
    pension.welfare_pension_insurance_all = json['pension'].to_f
    pension.welfare_pension_insurance_half = json['pensionHalf'].to_f
    pension
  end

  def get_insurance(ym, prefecture_code, base_salary)
    response = http.get('/user/insurance/show', :prefectureId => prefecture_code.to_i, :ym => ym, :baseSalary => base_salary)
    json = ActiveSupport::JSON.decode(response)

    insurance = Insurance.new
    insurance.apply_start_ym = json['startYm'].to_i
    insurance.apply_end_ym = json['endYm'].to_i
    insurance.grade = json['grade'].to_i
    insurance.pay_range_above = json['startSalary'].to_i
    insurance.pay_range_under = json['endSalary'].to_i
    insurance.monthly_earnings = json['baseSalary'].to_i
    insurance.health_insurance_all = json['insurance'].to_f
    insurance.health_insurance_half = json['insuranceHalf'].to_f
    insurance.health_insurance_all_care = json['insurance2'].to_f
    insurance.health_insurance_half_care = json['insurance2Half'].to_f
    insurance
  end
  
  # 標準報酬の基本情報を取得
  def get_basic_info(ym, prefecture_code, base_salary)
    raise '年月が未指定です。' unless ym

    date = Date.strptime("#{ym}01", '%Y%m%d')
    si = TaxJp::SocialInsurance.find_by_date_and_prefecture_and_salary(date, prefecture_code, base_salary)

    insurance = convert_tax_jp(si, :as => 'grade')
  end

  private

  def http
    @http ||= Daddy::HttpClient.new(HYACC_MASTER_URL)
  end

end