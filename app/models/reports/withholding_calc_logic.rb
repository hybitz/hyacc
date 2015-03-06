module Reports
  class WithholdingCalcLogic < BaseLogic
    def get_withholding_info
      model = WithholdingCalc.new
      model.calendar_year = @finder.calendar_year
      model.company = Company.find(@finder.company_id)
      model.total_salarys = get_total_salarys
      model.total_salarys.each do |ymd, amount|
        model.total_salary_1H = model.total_salary_1H + amount if ymd.slice(4, 2).to_i <= 6
      end
      model.total_salarys.each do |ymd, amount|
        model.total_salary_2H = model.total_salary_2H + amount if ymd.slice(4, 2).to_i > 6
      end
      model.total_salary_FY = model.total_salary_1H + model.total_salary_2H
      model.withholding_taxes = get_withholding_taxes
      model.withholding_taxes.each do |ymd, amount|
        model.withholding_tax_1H = model.withholding_tax_1H + amount if ymd.slice(4, 2).to_i <= 6
      end
      model.withholding_taxes.each do |ymd, amount|
        model.withholding_tax_2H = model.withholding_tax_2H + amount if ymd.slice(4, 2).to_i > 6
      end
      model.withholding_tax_FY = model.withholding_tax_1H + model.withholding_tax_2H
      
      model.total_bonuses = get_total_bonuses
      model.total_bonuses.each do |ymd, amount|
        model.total_bonus_1H = model.total_bonus_1H + amount if ymd.slice(4, 2).to_i <= 6
      end
      model.total_bonuses.each do |ymd, amount|
        model.total_bonus_2H = model.total_bonus_2H + amount if ymd.slice(4, 2).to_i > 6
      end
      model.total_bonus_FY = model.total_bonus_1H + model.total_bonus_2H
      
      model.withholding_taxes_of_bonus = get_withholding_taxes_of_bonus
      model.withholding_taxes_of_bonus.each do |ymd, amount|
        model.withholding_tax_of_bonus_1H = model.withholding_tax_of_bonus_1H + amount if ymd.slice(4, 2).to_i <= 6
      end
      model.withholding_taxes_of_bonus.each do |ymd, amount|
        model.withholding_tax_of_bonus_2H = model.withholding_tax_of_bonus_2H + amount if ymd.slice(4, 2).to_i > 6
      end
      model.withholding_tax_of_bonus_FY = model.withholding_tax_of_bonus_1H + model.withholding_tax_of_bonus_2H
      
      model
    end

    # 支払金額
    def get_total_salarys
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_base_salarys
    end
    
    # 支払金額(賞与)
    def get_total_bonuses
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_base_bonuses
    end
    
    # 源泉徴収税額
    def get_withholding_taxes
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_withholding_taxes_salary
    end
    
    def get_withholding_taxes_of_bonus
      logic = PayrollInfo::PayrollLogic.new(@finder)
      return logic.get_withholding_taxes_of_bonus
    end
  end
end
