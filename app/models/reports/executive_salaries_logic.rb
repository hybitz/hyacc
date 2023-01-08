module Reports
  class ExecutiveSalariesLogic < BaseLogic

    def build_model
      ret = ExecutiveSalariesModel.new
      ret.total_employee_salary_amount = get_this_term_amount(ACCOUNT_CODE_SALARY)

      company.employees.where(executive: true).each do |e|
        detail = ExecutiveSalariesDetailModel.new
        detail.employee_name = e.fullname
        detail.fixed_regular_salary_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_SALARY, e.id)
        ret.add_detail(detail)
      end
      
      ret
    end

  end

  class ExecutiveSalariesModel
    attr_accessor :total_employee_salary_amount
    attr_accessor :details

    def add_detail(detail)
      self.details ||= []
      self.details << detail
    end

    def sorted_details
      @sorted_details ||= details.sort{|a, b| a.salary_amount <=> b.salary_amount }.reverse
    end
  
    def total_executive_fixed_regular_salary_amount
      details.inject(0){|sum, detail| sum += detail.fixed_regular_salary_amount.to_i }
    end

    def total_executive_salary_amount
      total_executive_fixed_regular_salary_amount
    end

    def taotal_salary_amount
      total_executive_fixed_regular_salary_amount + total_employee_salary_amount
    end

  end
  
  class ExecutiveSalariesDetailModel
    attr_accessor :employee_name
    # 定期同額給与
    attr_accessor :fixed_regular_salary_amount

    def salary_amount
      fixed_regular_salary_amount
    end
  end

end
