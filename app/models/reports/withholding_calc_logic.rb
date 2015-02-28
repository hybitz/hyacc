module Reports
  class WithholdingCalcLogic < BaseLogic
    def get_withholding_info
      model = WithholdingCalc.new
      model.calendar_year = @finder.calendar_year
      model.company = Company.find(@finder.company_id)
      model.total_salarys = get_total_salarys
      model.total_salarys.each do |ym, amount|
        model.total_salary_1H = model.total_salary_1H + amount if ym.to_s.slice(4, 2).to_i <= 6
      end
      model.total_salarys.each do |ym, amount|
        model.total_salary_2H = model.total_salary_2H + amount if ym.to_s.slice(4, 2).to_i > 6
      end
      model.total_salary_FY = model.total_salary_1H + model.total_salary_2H
      model.withholding_taxes = get_withholding_taxes
      model.withholding_taxes.each do |ym, amount|
        model.withholding_tax_1H = model.withholding_tax_1H + amount if ym.to_s.slice(4, 2).to_i <= 6
      end
      model.withholding_taxes.each do |ym, amount|
        model.withholding_tax_2H = model.withholding_tax_2H + amount if ym.to_s.slice(4, 2).to_i > 6
      end
      model.withholding_tax_FY = model.withholding_tax_1H + model.withholding_tax_2H
      model
    end

    # 支払金額
    def get_total_salarys
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_base_salarys
    end
    
    # 源泉徴収税額
    def get_withholding_taxes
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_withholding_taxes
    end
    
  end
end
