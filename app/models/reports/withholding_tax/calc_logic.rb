module Reports
  module WithholdingTax

    # 給与所得・退職所得等の所得税徴収高計算書
    class CalcLogic < BaseLogic
  
      def get_withholding_info
        model = CalcModel.new
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
        model.overpayment = previous_overpayment((@finder.calendar_year.to_i - 1).to_s)
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
  
          if emp.employment_date > (@finder.calendar_year.to_s + "-12-31").to_date
            next
          end
          if !emp.retirement_date.nil? && emp.retirement_date < (@finder.calendar_year.to_s + "-01-01").to_date
            next
          end
  
          logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year.to_s, @finder.employee_id)
          w = logic.get_withholding_tax
          t = w + t
        end
        return t
      rescue => e
        Rails.logger.info e.message
        Rails.logger.info e.backtrace.join("\n")
        # 源泉徴収情報が未登録の場合はnil
        return nil
      end
      
      def previous_overpayment(previous_year)
        logic = PayrollInfo::PayrollLogic.new(previous_year, @finder.employee_id)
        all_withholding_taxes_1H = logic.get_all_withholding_taxes_1H
        annual_tax = 0
        c = Company.find(@finder.company_id)
        c.employees.each do |emp|
          @finder.employee_id = emp.id
  
          if emp.employment_date > (previous_year + "-12-31").to_date
            next
          end
          if !emp.retirement_date.nil? && emp.retirement_date < (previous_year + "-01-01").to_date
            next
          end
  
          logic = PayrollInfo::PayrollLogic.new(previous_year, @finder.employee_id)
          w = logic.get_withholding_tax
          annual_tax = w + annual_tax
        end
        
        annual_tax - all_withholding_taxes_1H < 0 ? annual_tax - all_withholding_taxes_1H : 0
      end
    end

    class CalcModel
      attr_accessor :calendar_year
      attr_accessor :company
      attr_accessor :total_salarys #給与支払金額()
      attr_accessor :withholding_taxes #給与源泉徴収税額()
      attr_accessor :total_salary_1H #給与上期支払金額
      attr_accessor :withholding_tax_1H #給与上期源泉徴収税額
      attr_accessor :total_salary_2H #給与下期支払金額
      attr_accessor :withholding_tax_2H #給与下期源泉徴収税額
      attr_accessor :total_salary_FY #給与通期支払金額
      attr_accessor :withholding_tax_FY #給与通期源泉徴収税額
  
      attr_accessor :total_bonuses #賞与支払金額()
      attr_accessor :withholding_taxes_of_bonus #賞与源泉徴収税額()
      attr_accessor :total_bonus_1H #賞与上期支払金額
      attr_accessor :withholding_tax_of_bonus_1H #賞与上期源泉徴収税額
      attr_accessor :total_bonus_2H #賞与下期支払金額
      attr_accessor :withholding_tax_of_bonus_2H #賞与下期源泉徴収税額
      attr_accessor :total_bonus_FY #賞与通期支払金額
      attr_accessor :withholding_tax_of_bonus_FY #賞与通期源泉徴収税額
      
      attr_accessor :tax_adjustment #年末調整額
      attr_accessor :overpayment # 過払い分
      
      def initialize
        self.total_salary_1H = 0
        self.withholding_tax_1H = 0
        self.total_salary_2H = 0
        self.withholding_tax_2H = 0
        self.total_salary_FY = 0
        self.withholding_tax_FY = 0
        
        self.total_bonus_1H = 0
        self.withholding_tax_of_bonus_1H = 0
        self.total_bonus_2H = 0
        self.withholding_tax_of_bonus_2H = 0
        self.total_bonus_FY = 0
        self.withholding_tax_of_bonus_FY = 0
      end
    end

  end
end
