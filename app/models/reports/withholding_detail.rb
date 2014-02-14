# -*- encoding : utf-8 -*-
#
# $Id: withholding_detail.rb 3132 2013-08-16 05:46:04Z hiro $
# Product: hyacc
# Copyright 2013 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
  class WithholdingDetail
    attr_accessor :fiscal_year
    attr_accessor :head_business_office
    attr_accessor :employee
    attr_accessor :company
    attr_accessor :total_salary #支払金額
    attr_accessor :exemption #控除額金額
    attr_accessor :after_exemption #控除後金額
    attr_accessor :withholding_tax #源泉徴収税額
    attr_accessor :social_insurance # 社会保険料等の金額
    attr_accessor :life_insurance_deduction # 生命保険料の控除額
  end
end
