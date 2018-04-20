module Reports
  class WithholdingSummaryLogic

    def initialize(finder)
      @finder = finder
    end

    def get_withholding_info
      model = WithholdingSummary.new
      model.calendar_year = @finder.calendar_year
      model.company = Company.find(@finder.company_id)
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
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        total_base_salary = total_base_salary + logic.get_total_base_salary
      end

      total_base_salary
    end

    # 源泉徴収税額
    def get_withholding_tax
      total_withholding_tax = 0
      c = Company.find(@finder.company_id)
      c.employees.each do |emp|
        @finder.employee_id = emp.id
        if emp.employment_date > (@finder.calendar_year + "-12-31").to_date
          next
        end
        if !emp.retirement_date.nil? && emp.retirement_date < (@finder.calendar_year + "-01-01").to_date
          next
        end
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        total_withholding_tax = total_withholding_tax + logic.get_withholding_tax
      end

      total_withholding_tax
    end
  end
end
