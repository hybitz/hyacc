module Reports
  class WithholdingSummaryLogic < BaseLogic

    def get_withholding_info
      model = WithholdingSummary.new
      model.calendar_year = @finder.calendar_year
      model.company = Company.find(@finder.company_id)
      model.head_business_office = model.company.get_head_business_office
      model.total_salary = get_total_salary                               # 支払金額
      model.withholding_tax = get_withholding_tax                         # 源泉徴収税額
      model
    end
    
    # 支払金額
    def get_total_salary
      total_base_salary = 0
      c = Company.find(@finder.company_id)
      c.employees.each do |emp|
        @finder.employee_id = emp.id
        logic = PayrollInfo::PayrollLogic.new(@finder)
        total_base_salary = total_base_salary + logic.get_total_base_salary
      end
      
      return total_base_salary
    end
    
    # 源泉徴収税額
    def get_withholding_tax
      total_withholding_tax = 0
      c = Company.find(@finder.company_id)
      c.employees.each do |emp|
        @finder.employee_id = emp.id
        logic = PayrollInfo::PayrollLogic.new(@finder)
        total_withholding_tax = total_withholding_tax + logic.get_withholding_tax
      end
      
      return total_withholding_tax
    end
  end
end
