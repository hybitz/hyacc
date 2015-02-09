class HyaccMaster::Cache
  require 'hyacc_master/service'

  # キー：都道府県一覧
  MEM_KEY_PREFECTURE_LIST = "MEM_KEY_PREFECTURE_LIST"
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
  
  # 都道府県一覧を取得する
  def get_prefectures
    prefectures = Rails.cache.read(MEM_KEY_PREFECTURE_LIST)
    if prefectures.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + MEM_KEY_PREFECTURE_LIST
      end
      service = HyaccMaster::Service.new
      prefectures = service.get_prefectures
      Rails.cache.write(MEM_KEY_PREFECTURE_LIST, prefectures)
    end
    prefectures
  end

  def get_insurances(prefecture_id, ym, base_salary)
    key = MEM_KEY_INSURANCE_LIST + create_sub_key([prefecture_id, ym, base_salary])
    insurances = Rails.cache.read(key)
    if insurances.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      service = HyaccMaster::Service.new
      insurances = service.get_insurances(prefecture_id, ym, base_salary)
      Rails.cache.write(key, insurances)
    end
    insurances
  end

  def get_insurance(ym = nil, prefecture_id = nil, base_salary = 0)
    key = MEM_KEY_INSURANCE + create_sub_key([ym, prefecture_id, base_salary])
    insurance = Rails.cache.read(key)
      HyaccLogger.debug "20150101:cache insurance=" + insurance.to_s
      HyaccLogger.debug "20150101:insuranceがnilか？"
    if insurance.nil?
      HyaccLogger.debug "20150101:insuranceがnilだよ"
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      service = HyaccMaster::Service.new
      HyaccLogger.debug "20150101: ym/prefecture_id/base_salary=" + ym.to_s + "/" + prefecture_id.to_s + "/" + base_salary.to_s
      insurance = service.get_insurance(ym, prefecture_id, base_salary)
      HyaccLogger.debug "20150101:realllllllllllll insurance=" + insurance.to_s
      Rails.cache.write(key, insurance)
    end
      HyaccLogger.debug "20150101:return insurance=" + insurance.to_s
    insurance
  end
  
  def get_pensions(ym = nil, base_salary = 0)
    key = MEM_KEY_PENSION_LIST + create_sub_key([ym, base_salary])
    pension = Rails.cache.read(key)
    if pension.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      service = HyaccMaster::Service.new
      pensions = service.get_pensions(ym, base_salary)
      Rails.cache.write(key, pensions)
    end
    pension
  end

  def get_pension(ym = nil, base_salary = 0)
    key = MEM_KEY_PENSION + create_sub_key([ym, base_salary])
    pension = Rails.cache.read(key)
    if pension.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      service = HyaccMaster::Service.new
      pension = service.get_pension(ym, base_salary)
      Rails.cache.write(key, pension)
    end
    pension
  end

  #標準報酬の基本情報を取得
  # TODO get_basic_infoだけキャッシュがきいていない
  def get_basic_info(ym = nil, base_salary = 0)
    key = MEM_KEY_BASIC_INFO + create_sub_key([ym, base_salary])
    insurance = Rails.cache.read(key)
    if insurance.nil?
      if HyaccLogger.debug?
        HyaccLogger.debug "Cache not found " + key
      end
      service = HyaccMaster::Service.new
      insurance = service.get_basic_info(ym, base_salary)
      Rails.cache.write(key, insurance)
    end
    insurance
  end
  
  private

  # サブキーの生成
  def create_sub_key(options = [])
    key = ""
    options.each do |option|
      key = key + SEPARATOR + option.to_s
    end
    key
  end
  
end