module Depreciation::DepreciationUtil
  include HyaccConst

  def self.create_depreciations(asset)
    get_strategy(asset.depreciation_method).create_depreciations(asset)
  end
  
  # 減価償却仕訳の作成
  def self.make_journals(depreciation, user)
    param = Auto::Journal::DepreciationParam.new(depreciation, user)
    factory = Auto::AutoJournalFactory.get_instance(param)
    factory.make_journals.each do |jh|
      JournalUtil.validate_journal(jh)
    end
  end

  def self.get_strategy(depreciation_method)
    case depreciation_method
    when DEPRECIATION_METHOD_FIXED_AMOUNT
      Depreciation::Strategy::FixedAmount.new
    when DEPRECIATION_METHOD_FIXED_RATE
      Depreciation::Strategy::FixedRate.new
    when DEPRECIATION_METHOD_LUMP
      Depreciation::Strategy::Lump.new
    else
      raise HyaccException.new("予期していない償却方法です。[#{depreciation_method}]")
    end
  end
  
end
