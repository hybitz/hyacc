# -*- encoding : utf-8 -*-
module Reports
  class WithholdingCalc
    attr_accessor :calendar_year
    attr_accessor :company
    attr_accessor :total_salarys #支払金額
    attr_accessor :withholding_taxes #源泉徴収税額
    attr_accessor :total_salary_1H #上期支払金額
    attr_accessor :withholding_tax_1H #上期源泉徴収税額
    attr_accessor :total_salary_2H #下期支払金額
    attr_accessor :withholding_tax_2H #下期源泉徴収税額
    attr_accessor :total_salary_FY #通期支払金額
    attr_accessor :withholding_tax_FY #通期源泉徴収税額
    
    def initialize
      self.total_salary_1H = 0
      self.withholding_tax_1H = 0
      self.total_salary_2H = 0
      self.withholding_tax_2H = 0
      self.total_salary_FY = 0
      self.withholding_tax_FY = 0
    end
  end
end
