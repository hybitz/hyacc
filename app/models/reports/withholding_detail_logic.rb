# -*- encoding : utf-8 -*-
module Reports
  class WithholdingDetailLogic < BaseLogic
    require 'gengou'
    
    def initialize(finder)
      super(finder)
    end
    
    def get_withholding_info
      model = WithholdingDetail.new
      model.calendar_year = @finder.calendar_year
      model.company = Company.find(@finder.company_id)
      model.head_business_office = model.company.get_head_business_office
      model.employee = Employee.find(@finder.employee_id)
      model.total_salary = get_total_salary                               # 支払金額
      model.exemption = get_exemption                                     # 所得控除の額の合計
      model.after_deduction = get_after_deduction                         # 給与所得控除後の金額
      model.withholding_tax = get_withholding_tax                         # 源泉徴収税額
      model.social_insurance = get_social_insurance                       # 社会保険料等の金額
      model.life_insurance_deduction = get_life_insurance_deduction       # 住宅借入金等特別控除の額
      model
    end
    
    # 支払金額
    def get_total_salary
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_total_base_salary
    end
    
    # 所得控除の額の合計
    def get_exemption
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_exemption
    end
    
    # 給与所得控除後の金額
    def get_after_deduction
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_after_deduction
    end
    
    # 源泉徴収税額
    def get_withholding_tax
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_withholding_tax
    end
    
    # 社会保険料等の金額
    def get_social_insurance
      return 200000
    end
    
    # 生命保険料の控除額
    def get_life_insurance_deduction
      return 40000
    end
      
  end
end
