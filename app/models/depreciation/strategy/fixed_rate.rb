module Depreciation::Strategy
    
  # 定率法
  class FixedRate < Depreciation::Strategy::Base

    def create_depreciations(asset)
      c = asset.branch.company
      dr = DepreciationRate.find_by_date_and_durable_years(asset.date, asset.durable_years)
      
      # 初年度の償却可能額を算定するための月数
      num_of_months = HyaccDateUtil.get_remaining_months(c.start_month_of_fiscal_year, asset.ym)
      # 償却補償額  = 取得価額 x 保証率
      guaranteed_amount = round_depreciation_amount(asset.amount * dr.guaranteed_rate, c)
      
      if HyaccLogger.debug?
        HyaccLogger.debug "#{dr.to_yaml}\n初年度償却対象月数：#{num_of_months}ヶ月、償却補償額：#{guaranteed_amount}"
      end

      ret = []
      fiscal_year = c.get_fiscal_year_int(asset.ym)
      amount = asset.amount
      
      # 通常の償却率での計算
      while true
        d = asset.depreciations.build
        d.fiscal_year = fiscal_year
        d.amount_at_start = amount
        
        # 償却額の計算
        if ret.empty?
          depreciation_amount = round_depreciation_amount(amount * num_of_months * dr.rate / 12, c)
        else
          depreciation_amount = round_depreciation_amount(amount * dr.rate, c)

          # 償却補償額を下回った時点で改定償却率での計算に切り替える
          if depreciation_amount < guaranteed_amount
            d.mark_for_destruction
            break
          end
        end
        
        if (amount - depreciation_amount) > asset.depreciation_limit
          amount -= depreciation_amount
          d.amount_at_end = amount
          ret << d
          fiscal_year += 1
        else
          amount = asset.depreciation_limit
          d.amount_at_end = amount
          ret << d
          break
        end
      end
      
      # 償却限度額に達していれば終了
      return ret if amount == asset.depreciation_limit
      
      # 改定後償却額
      depreciation_amount = round_depreciation_amount(amount * dr.revised_rate, c)
      HyaccLogger.debug "改定後償却額：#{depreciation_amount}"
      
      # 改定償却率での計算
      while true
        d = asset.depreciations.build
        d.fiscal_year = fiscal_year
        d.amount_at_start = amount

        if (amount - depreciation_amount) > asset.depreciation_limit
          amount -= depreciation_amount
          d.amount_at_end = amount
          ret << d
          fiscal_year += 1
        else
          d.amount_at_end = asset.depreciation_limit
          ret << d
          break
        end
      end

      ret
    end
  end
  
end
