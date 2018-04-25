module PayrollInfo
  class PayrollModel
    attr_accessor :fiscal_year
    attr_accessor :base_salary    # 基本給
    attr_accessor :extra_pay      # 割増賃金
    attr_accessor :insurance      # 個人負担健康保険料
    attr_accessor :pension        # 個人負担厚生年金保険料
    attr_accessor :inhabitant_tax # 住民税
    attr_accessor :income_tax     # 源泉所得税

    attr_accessor :exemption #控除額金額
    attr_accessor :after_exemption #控除後金額
    attr_accessor :withholding_tax #源泉徴収税額
    attr_accessor :social_insurance # 社会保険料等の金額
    attr_accessor :life_insurance_deduction # 生命保険料の控除額
    
    def initialize
      @base_salary = 0
      @extra_pay = 0
      @insurance = 0
      @pension = 0
      @inhabitant_tax = 0
      @income_tax = 0
    end
    
    def sub_total
      @base_salary + @extra_pay
    end
    def total
      sub_total
    end
  end
end
