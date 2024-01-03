module Reports
  module WithholdingTax

    class BaseLogic < Reports::BaseLogic
      def calendar_year
        finder.calendar_year.to_i
      end

      protected

      def payroll_logic
        @payroll_logic ||= PayrollInfo::PayrollLogic.new(calendar_year, finder.employee_id)
      end
    end
  
  end
end
