module Reports
  module WithholdingTax

    class SummaryLogic < BaseLogic

      def get_withholding_info
        model = SummaryModel.new
        model.calendar_year = @finder.calendar_year
        model.company = Company.find(@finder.company_id)
        model.total_salary_except_previous = get_total_salary_except_previous                # 支払金額
        model.withholding_tax_except_previous = get_withholding_tax_except_previous          # 源泉徴収税額
        model.total_salary_include_previous = get_total_salary                               # 支払金額(前職を含む)
        model.withholding_tax_include_previous = get_withholding_tax                         # 源泉徴収税額(前職を含む)
        model
      end
  
      # 支払金額(前職を含む)
      def get_total_salary
        total_base_salary = 0
        employees.each do |emp|
          @finder.employee_id = emp.id
          logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
          total_base_salary = total_base_salary + logic.get_total_base_salary_include_previous
        end
        
        total_base_salary
      end
      
      # 源泉徴収税額(前職を含む)
      def get_withholding_tax
        total_withholding_tax = 0
        employees.each do |emp|
          @finder.employee_id = emp.id
          logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
          total_withholding_tax = total_withholding_tax + logic.get_withholding_tax
        end
        
        total_withholding_tax
      end
  
      # 支払金額(前職を除く)
      def get_total_salary_except_previous
        total_base_salary = 0
        employees.each do |emp|
          @finder.employee_id = emp.id
          logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
          total_base_salary = total_base_salary + logic.get_total_base_salary
        end
        
        total_base_salary
      end
      
  
      # 源泉徴収税額(前職を除く)
      def get_withholding_tax_except_previous
        total_withholding_tax = 0
        employees.each do |emp|
          @finder.employee_id = emp.id
          logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
          e = logic.get_exemptions
          total_withholding_tax = total_withholding_tax + logic.get_withholding_tax - e.previous_withholding_tax.to_i
        end
        
        total_withholding_tax
      end
  
      private
  
      def employees
        employees = []
        c = Company.find(@finder.company_id)
        c.employees.each do |emp|
          if emp.employment_date > (@finder.calendar_year.to_s + "-12-31").to_date
            next
          end
          if !emp.retirement_date.nil? && emp.retirement_date < (@finder.calendar_year.to_s + "-01-01").to_date
            next
          end
          employees << emp
        end
        employees
      end
    end

    class SummaryModel
      attr_accessor :calendar_year
      attr_accessor :company
      attr_accessor :total_salary_except_previous     #支払金額
      attr_accessor :withholding_tax_except_previous  #源泉徴収税額
      attr_accessor :total_salary_include_previous    #支払金額(前職を含む)
      attr_accessor :withholding_tax_include_previous #源泉徴収税額(前職を含む)
    end

  end
end
