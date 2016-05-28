module Depreciation::Strategy
  # 一括償却
  class Lump < Depreciation::Strategy::Base

    def create_depreciations(asset)
      d = asset.depreciations.build
      d.fiscal_year = asset.branch.company.get_fiscal_year_int(asset.ym)
      d.amount_at_start = asset.amount
      d.amount_at_end = 0
    end
  end
end
