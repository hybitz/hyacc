# -*- encoding : utf-8 -*-
#
# $Id: base.rb 2476 2011-03-23 15:29:06Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Depreciation::Strategy
  class Base
    include HyaccDateUtil

  protected
    # 減価償却費の丸め処理
    # 個人事業主は切り上げ、それ以外は切り捨て
    def round_depreciation_amount(amount, company)
      if company.type_of == COMPANY_TYPE_PERSONAL
        amount.ceil
      else
        amount.truncate
      end
    end

  end  
end
