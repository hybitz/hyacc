class HyaccMaster::Cache
  # キー：厚生年金保険料一覧
  MEM_KEY_PENSION_LIST = "MEM_KEY_PENSION_LIST"
  # キー：健康保険料一覧
  MEM_KEY_INSURANCE_LIST = "MEM_KEY_INSURANCE_LIST"
  # キー：厚生年金保険料
  MEM_KEY_PENSION = "MEM_KEY_PENSION"
  # キー：健康保険料
  MEM_KEY_INSURANCE = "MEM_KEY_INSURANCE"
  # キー：基本情報
  MEM_KEY_BASIC_INFO = "MEM_KEY_BASIC_INFO"
  
  SEPARATOR = "-"
  
  def get_insurances(prefecture_code, ym, base_salary)
    key = MEM_KEY_INSURANCE_LIST + create_sub_key([prefecture_code, ym, base_salary])
    insurances = Rails.cache.read(key)
    if insurances.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      insurances = service.get_insurances(prefecture_code, ym, base_salary)
      Rails.cache.write(key, insurances)
    end
    insurances
  end

  def get_insurance(ym, prefecture_code, base_salary)
    key = MEM_KEY_INSURANCE + create_sub_key([ym, prefecture_code, base_salary])
    insurance = Rails.cache.read(key)
    if insurance.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      insurance = service.get_insurance(ym, prefecture_code, base_salary)
      Rails.cache.write(key, insurance)
    end
    insurance
  end
  
  def get_pensions(prefecture_code, ym, base_salary)
    key = MEM_KEY_PENSION_LIST + create_sub_key([ym, base_salary])
    pensions = Rails.cache.read(key)
    if pensions.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      pensions = service.get_pensions(prefecture_code, ym, base_salary)
      Rails.cache.write(key, pensions)
    end
    pensions
  end

  def get_pension(ym, prefecture_code, base_salary)
    key = MEM_KEY_PENSION + create_sub_key([ym, prefecture_code, base_salary])
    pension = Rails.cache.read(key)
    if pension.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      pension = service.get_pension(ym, prefecture_code, base_salary)
      Rails.cache.write(key, pension)
    end
    pension
  end

  #標準報酬の基本情報を取得
  # TODO get_basic_infoだけキャッシュがきいていない
  def get_basic_info(ym, prefecture_code, base_salary)
    key = MEM_KEY_BASIC_INFO + create_sub_key([ym, prefecture_code, base_salary])
    insurance = Rails.cache.read(key)
    if insurance.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      insurance = service.get_basic_info(ym, prefecture_code, base_salary)
      Rails.cache.write(key, insurance)
    end
    insurance
  end
  
  private

  def service
    @service ||= HyaccMaster::Service.new
  end

  # サブキーの生成
  def create_sub_key(options = [])
    key = ""
    options.each do |option|
      key = key + SEPARATOR + option.to_s
    end
    key
  end
  
end