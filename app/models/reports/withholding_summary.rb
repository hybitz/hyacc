# -*- encoding : utf-8 -*-
module Reports
  class WithholdingSummary
    attr_accessor :calendar_year
    attr_accessor :head_business_office
    attr_accessor :company
    attr_accessor :total_salary #支払金額
    attr_accessor :withholding_tax #源泉徴収税額
  end
end
