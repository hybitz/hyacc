module Depreciation::Strategy
    
  # 定額法
  class FixedAmount < Depreciation::Strategy::Base

    def create_depreciations(asset)
      c = asset.branch.company
      dr = DepreciationRate.find_by_date_and_durable_years(asset.date, asset.durable_years)
      
      # 初年度の償却可能額を算定するための月数
      num_of_months = get_remaining_months(c.start_month_of_fiscal_year, asset.ym)
      # 償却額
      depreciation_amount = round_depreciation_amount(asset.amount * dr.fixed_amount_rate, c)
      
      if HyaccLogger.debug?
        HyaccLogger.debug "初年度償却対象月数：#{num_of_months}ヶ月、償却額：#{depreciation_amount}"
      end
      
      ret = []
      fiscal_year = c.get_fiscal_year_int(asset.ym)
      amount = asset.amount
      
      while true
        d = Depreciation.new
        d.fiscal_year = fiscal_year
        d.amount_at_start = amount
        
        # 償却額の計算
        if ret.size == 0
          amount -= round_depreciation_amount(depreciation_amount * num_of_months / 12, c)
        else
          amount -= depreciation_amount 
        end
        
        # 償却限度額に達した時点で終了
        if amount <= asset.depreciation_limit
          d.amount_at_end = asset.depreciation_limit
          ret << d
          break
        end
        
        d.amount_at_end = amount
        ret << d
        fiscal_year += 1
      end
      
      ret
    end
  end
  
end
