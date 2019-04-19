module Reports
  class WithholdingCalc
    attr_accessor :calendar_year
    attr_accessor :company
    attr_accessor :total_salarys #給与支払金額()
    attr_accessor :withholding_taxes #給与源泉徴収税額()
    attr_accessor :total_salary_1H #給与上期支払金額
    attr_accessor :withholding_tax_1H #給与上期源泉徴収税額
    attr_accessor :total_salary_2H #給与下期支払金額
    attr_accessor :withholding_tax_2H #給与下期源泉徴収税額
    attr_accessor :total_salary_FY #給与通期支払金額
    attr_accessor :withholding_tax_FY #給与通期源泉徴収税額

    attr_accessor :total_bonuses #賞与支払金額()
    attr_accessor :withholding_taxes_of_bonus #賞与源泉徴収税額()
    attr_accessor :total_bonus_1H #賞与上期支払金額
    attr_accessor :withholding_tax_of_bonus_1H #賞与上期源泉徴収税額
    attr_accessor :total_bonus_2H #賞与下期支払金額
    attr_accessor :withholding_tax_of_bonus_2H #賞与下期源泉徴収税額
    attr_accessor :total_bonus_FY #賞与通期支払金額
    attr_accessor :withholding_tax_of_bonus_FY #賞与通期源泉徴収税額
    
    attr_accessor :tax_adjustment #年末調整額
    attr_accessor :overpayment # 過払い分
    
    def initialize
      self.total_salary_1H = 0
      self.withholding_tax_1H = 0
      self.total_salary_2H = 0
      self.withholding_tax_2H = 0
      self.total_salary_FY = 0
      self.withholding_tax_FY = 0
      
      self.total_bonus_1H = 0
      self.withholding_tax_of_bonus_1H = 0
      self.total_bonus_2H = 0
      self.withholding_tax_of_bonus_2H = 0
      self.total_bonus_FY = 0
      self.withholding_tax_of_bonus_FY = 0
    end
  end
end
