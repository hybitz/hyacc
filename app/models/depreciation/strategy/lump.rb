# -*- encoding : utf-8 -*-
#
# $Id: lump.rb 2476 2011-03-23 15:29:06Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Depreciation::Strategy
  # 一括償却
  class Lump < Depreciation::Strategy::Base
    include HyaccDateUtil

    def create_depreciations(asset)
      ret = []

      d = Depreciation.new
      d.fiscal_year = asset.branch.company.get_fiscal_year_int(asset.ym)
      d.amount_at_start = asset.amount
      d.amount_at_end = 0
      ret << d
      
      ret
    end
  end
end
