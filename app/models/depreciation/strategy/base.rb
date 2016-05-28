module Depreciation::Strategy
  class Base

    protected

    # 減価償却費の丸め処理
    # 個人事業主は切り上げ、それ以外は切り捨て
    def round_depreciation_amount(amount, company)
      if company.personal?
        amount.ceil
      else
        amount.truncate
      end
    end

  end  
end
