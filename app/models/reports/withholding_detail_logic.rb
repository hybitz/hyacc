module Reports
  class WithholdingDetailLogic

    def initialize(finder)
      @finder = finder
    end

    def get_withholding_info
      model = WithholdingDetail.new
      model.calendar_year = @finder.calendar_year
      model.company = Company.find(@finder.company_id)
      model.head_business_office = model.company.head_branch.business_office_on("#{model.calendar_year}-12-31")
      model.employee = Employee.find(@finder.employee_id)
      model.total_salary = get_total_salary                       # 支払金額
      model.exemption_amount = get_total_exemption                # 所得控除の額の合計
      model.after_deduction = get_after_deduction                 # 給与所得控除後の金額
      model.withholding_tax = get_withholding_tax                 # 源泉徴収税額
      model.social_insurance = get_social_insurance               # 社会保険料等の金額
      model.exemption = get_exemptions                            # 配偶者控除額
      model
    end
    
    def has_exemption?
      Exemption.get(@finder.employee_id, @finder.calendar_year).present?
    end

    private

    # 支払金額
    def get_total_salary
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      return logic.get_total_base_salary
    end
    
    # 控除額
    def get_exemptions
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      logic.get_exemptions
    end
    
    # 所得控除の額の合計
    def get_total_exemption
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      logic.get_exemption
    end
    
    # 給与所得控除後の金額
    def get_after_deduction
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      logic.get_after_deduction
    end
    
    # 源泉徴収税額
    def get_withholding_tax
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      logic.get_withholding_tax
    end
    
    # 社会保険料等の金額(健康保険料＋厚生年金保険料＋小規模共済)
    def get_social_insurance
      logic = PayrollInfo::PayrollLogic.new(@finder.calendar_year, @finder.employee_id)
      e = logic.get_exemptions
      logic.get_health_insurance + logic.get_employee_pention + e.small_scale_mutual_aid.to_i
    end

  end
end
