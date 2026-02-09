module Reports
  module WithholdingTax

    # 給与所得の源泉徴収票
    class DetailLogic < Reports::WithholdingTax::BaseLogic
  
      def get_withholding_info
        model = DetailModel.new
        model.calendar_year = @finder.calendar_year
        model.company = Company.find(@finder.company_id)
        model.head_business_office = model.company.head_branch.business_office_on("#{model.calendar_year}-12-31")
        employee = Employee.find(@finder.employee_id)
        model.employee = employee
        model.total_salary = get_total_salary                       # 支払金額
        model.after_deduction = get_after_deduction                 # 給与所得控除後の金額
        model.exemption_amount = get_total_exemption                # 所得控除の額の合計
        model.withholding_tax = get_withholding_tax                 # 源泉徴収税額
        model.mortgage_deduction = get_mortgage_deduction
        model.mortgage_deductible = get_mortgage_deductible
        model.income_adjustment_deduction = get_income_adjustment_deduction   # 所得金額調整控除額
        model.social_insurance = get_social_insurance               # 給与から控除された社会保険料等の金額
        e = get_exemptions
        model.exemption = e                                         # 配偶者控除額
        model.social_insurance_selfpay = e.social_insurance_selfpay # 給与から控除していない自己負担社会保険料
        model.small_scale_mutual_aid = e.small_scale_mutual_aid     # 小規模共済掛金
        if employee.retirement_date.present? && employee.retirement_date.year == @finder.calendar_year.to_i
          model.employment_or_retirement_date = employee.retirement_date   # 入退社日
          model.retirement_year = true
        end
        if employee.employment_date.present? && employee.employment_date.year == @finder.calendar_year.to_i
          model.employment_or_retirement_date = employee.employment_date   # 入退社日
          model.employment_year = true
        end
        model
      end
      
      def has_exemption?
        Exemption.get(@finder.employee_id, @finder.calendar_year).present?
      end
  
      private
  
      # 支払金額(前職を含む)
      def get_total_salary
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        return logic.get_total_base_salary_include_previous
      end
      
      # 控除額
      def get_exemptions
        payroll_logic.get_exemptions
      end
      
      # 所得控除の額の合計
      def get_total_exemption
        payroll_logic.get_total_exemption
      end

      # 給与所得控除後の金額
      def get_after_deduction
        payroll_logic.get_after_deduction
      end
      
      # 源泉徴収税額(前職を含む)
      def get_withholding_tax
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        logic.get_withholding_tax
      end
      
      # 社会保険料等の金額(健康保険料＋厚生年金保険料＋雇用保険料＋前職分の社会保険料等の金額)
      def get_social_insurance
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        e = logic.get_exemptions
  
        logic.get_health_insurance + logic.get_employee_pention + logic.get_employment_insurance + e.previous_social_insurance.to_i
      end
  
      def get_mortgage_deduction
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        e = logic.get_exemptions
        mortgage_deductible = e.max_mortgage_deduction.to_i
        withholding_tax_before_deduction = logic.get_withholding_tax_before_mortgage_deduction.to_i
        mortgage_deductible > withholding_tax_before_deduction ? withholding_tax_before_deduction : mortgage_deductible
      end
      
      def get_mortgage_deductible
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        e = logic.get_exemptions
        mortgage_deductible = e.max_mortgage_deduction.to_i
        withholding_tax_before_deduction = logic.get_withholding_tax_before_mortgage_deduction.to_i
        mortgage_deductible > withholding_tax_before_deduction ? mortgage_deductible : nil
      end

      def get_income_adjustment_deduction
        logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
        logic.get_income_adjustment_deduction
      end
    end

    class DetailModel
      attr_accessor :calendar_year
      attr_accessor :head_business_office
      attr_accessor :employee
      attr_accessor :company
      attr_accessor :total_salary # 支払金額
      attr_accessor :exemption_amount # 控除額金額
      attr_accessor :after_deduction # 控除後金額
      attr_accessor :withholding_tax # 源泉徴収税額
      attr_accessor :mortgage_deduction # 住宅ローン控除額
      attr_accessor :mortgage_deductible # 住宅ローン控除可能額
      attr_accessor :income_adjustment_deduction # 所得金額調整控除額
      attr_accessor :social_insurance # 社会保険料等の金額
      attr_accessor :small_scale_mutual_aid # 小規模共済掛金の金額
      attr_accessor :social_insurance_selfpay # 給与から控除していない自己負担社会保険料
      attr_accessor :life_insurance_deduction # 生命保険料の控除額
      attr_accessor :exemption # 控除情報
      attr_accessor :employment_or_retirement_date # 入退社日（レポート出力対象のみ設定）
      attr_accessor :employment_year # 入社年？
      attr_accessor :retirement_year # 退社年？
  
      def social_insurance_internal
        small_scale_mutual_aid.to_i + social_insurance_selfpay.to_i
      end
  
      def social_insurance_total
        social_insurance + social_insurance_internal
      end
    end

  end
end
