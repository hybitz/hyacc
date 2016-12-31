module Reports
  class WithholdingCalcLogic

    def initialize(finder)
      @finder = finder
    end

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
      
      annual_tax = get_annual_tax
      model.tax_adjustment = model.withholding_tax_FY + model.withholding_tax_of_bonus_FY - annual_tax if annual_tax # 年末調整額 = 源泉徴収全額 - 年調税額
      model
    end

    # 支払金額
    def get_total_salarys
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      return logic.get_base_salaries
    end
    
    # 支払金額(賞与)
    def get_total_bonuses
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      return logic.get_base_bonuses
    end
    
    # 源泉徴収税額
    def get_withholding_taxes
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      return logic.get_withholding_taxes_salary
    end
    
    def get_withholding_taxes_of_bonus
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      return logic.get_withholding_taxes_of_bonus
    end
    
    def get_annual_tax
      t = 0
      c = Company.find(@finder.company_id)
      c.employees.each do |emp|
        @finder.employee_id = emp.id
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        w = logic.get_withholding_tax
        t = w + t
      end
      return t
    rescue => e
      # 源泉徴収情報が未登録の場合はnil
      return nil
    end
  end
end
