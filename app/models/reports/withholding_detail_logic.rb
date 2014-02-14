# -*- encoding : utf-8 -*-
#
# $Id: withholding_detail_logic.rb 3132 2013-08-16 05:46:04Z hiro $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
  class WithholdingDetailLogic < BaseLogic
    require 'gengou'
    
    def initialize(finder)
      super(finder)
    end
    
    def get_withholding_info
      model = WithholdingDetail.new
      model.fiscal_year = @finder.fiscal_year
      model.company = Company.find(@finder.company_id)
      model.head_business_office = model.company.get_head_business_office
      model.employee = Employee.find(@finder.employee_id)
      model.total_salary = get_total_salary
      model.exemption = get_exemption
      model.after_exemption = get_after_exemption
      model.withholding_tax = get_withholding_tax
      model.social_insurance = get_social_insurance
      model.life_insurance_deduction = get_life_insurance_deduction
      model
    end
    
    # 支払金額
    def get_total_salary
      logic = PayrollInfo::PayrollLogic.new(@finder.fiscal_year)
      return logic.get_total_base_salary
    end
    
    # 所得控除の額の合計
    def get_exemption
      return 900000
    end
    
    # 給与所得控除後の金額
    def get_after_exemption
      return 3000000
    end
    
    # 源泉徴収税額
    def get_withholding_tax
      return 100000
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
