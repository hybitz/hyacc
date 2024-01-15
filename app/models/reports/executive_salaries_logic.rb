module Reports
  class ExecutiveSalariesLogic < BaseLogic

    def build_model
      ret = ExecutiveSalariesModel.new
      ret.total_employee_salary_amount = get_this_term_amount(ACCOUNT_CODE_SALARY)

      company.employees.where(executive: true).each do |e|
        detail = ExecutiveSalariesDetailModel.new
        detail.position = '代表取締役'
        detail.employee_name = e.fullname
        detail.relationship = '本人'
        detail.full_time = true
        detail.fixed_regular_salary_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_SALARY, e.id)
        detail.other_salary_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_BONUS, e.id)
        ret.add_detail(detail)
      end
      
      ret.fill_details(5)
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

    def fill_details(min_count)
      (details.size ... min_count).each do
        add_detail(ExecutiveSalariesDetailModel.new)
      end
    end

    def sorted_details
      @sorted_details ||= details.sort{|a, b| a.salary_amount.to_i <=> b.salary_amount.to_i }.reverse
    end
  
    def total_executive_fixed_regular_salary_amount
      details.inject(0){|sum, detail| sum += detail.fixed_regular_salary_amount.to_i }
    end

    def total_executive_other_salary_amount
      details.inject(0){|sum, detail| sum += detail.other_salary_amount.to_i }
    end

    def total_executive_salary_amount
      total_executive_fixed_regular_salary_amount + total_executive_other_salary_amount
    end

    def total_salary_amount
      total_executive_salary_amount + total_employee_salary_amount
    end

  end
  
  class ExecutiveSalariesDetailModel
    attr_accessor :position
    attr_accessor :employee_name
    attr_accessor :relationship
    attr_accessor :full_time
    # 定期同額給与
    attr_accessor :fixed_regular_salary_amount
    # その他
    attr_accessor :other_salary_amount

    def full_time?
      full_time
    end

    def salary_amount
      fixed_regular_salary_amount.to_i + other_salary_amount.to_i
    end
  end

end
