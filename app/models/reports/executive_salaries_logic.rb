module Reports
  class ExecutiveSalariesLogic < BaseLogic
    # 「従業員/賃金手当」の集計・表示は未対応
    def build_model
      ret = ExecutiveSalariesModel.new
      ret.total_employee_salary_amount = get_this_term_amount(ACCOUNT_CODE_SALARY)
      ret.total_employee_salary_amount_for_representative_or_family = get_employee_salary_amount_for_representative_or_family

      company.employees.where(executive: true).each do |e|
        detail = ExecutiveSalariesDetailModel.new
        detail.position = e.position
        detail.employee_name = e.fullname
        detail.relationship = e.relationship_to_representative
        detail.representative_or_family_type = e.representative_or_family_type
        detail.full_time = e.full_time
        detail.duty_description = e.duty_description
        detail.address = e.address_on(end_ymd)
        detail.fixed_regular_salary_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_SALARY, e.id)
        detail.other_salary_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_BONUS, e.id)
        detail.retirement_allowance_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_RETIREMENT, e.id)
        ret.add_detail(detail)
      end
      
      ret.fill_details(5)
      ret
    end

    private

    def get_employee_salary_amount_for_representative_or_family
      employee_ids = company.employees.where(
        executive: false,
        representative_or_family_type: [
          REPRESENTATIVE_OR_FAMILY_TYPE_REPRESENTATIVE,
          REPRESENTATIVE_OR_FAMILY_TYPE_FAMILY
        ]
      ).pluck(:id)
      return 0 if employee_ids.empty?

      get_this_term_amount(ACCOUNT_CODE_SALARY, employee_ids)
    end

  end

  class ExecutiveSalariesModel
    attr_accessor :total_employee_salary_amount
    attr_accessor :total_employee_salary_amount_for_representative_or_family
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
      details.sort_by do |detail|
        [detail.representative? ? 0 : 1, -detail.salary_amount.to_i]
      end
    end

    def total_executive_fixed_regular_salary_amount
      details.inject(0){|sum, detail| sum + detail.fixed_regular_salary_amount.to_i }
    end

    def total_executive_other_salary_amount
      details.inject(0){|sum, detail| sum + detail.other_salary_amount.to_i }
    end

    def total_executive_retirement_allowance_amount
      details.inject(0){|sum, detail| sum + detail.retirement_allowance_amount.to_i }
    end

    def total_executive_salary_amount
      total_executive_fixed_regular_salary_amount + total_executive_other_salary_amount
    end

    def total_salary_amount
      total_executive_salary_amount + total_employee_salary_amount
    end

    def total_executive_salary_amount_for_representative_or_family
      details.inject(0) do |sum, detail|
        sum + (detail.representative_or_family? ? detail.salary_amount.to_i : 0)
      end
    end

    def total_salary_amount_for_representative_or_family
      total_executive_salary_amount_for_representative_or_family + total_employee_salary_amount_for_representative_or_family.to_i
    end
  end

  class ExecutiveSalariesDetailModel
    include HyaccConst

    attr_accessor :position
    attr_accessor :employee_name
    attr_accessor :relationship
    attr_accessor :representative_or_family_type
    attr_accessor :full_time
    attr_accessor :duty_description
    attr_accessor :address
    # 定期同額給与
    attr_accessor :fixed_regular_salary_amount
    # その他
    attr_accessor :other_salary_amount
    attr_accessor :retirement_allowance_amount

    def full_time?
      full_time
    end

    def salary_amount
      fixed_regular_salary_amount.to_i + other_salary_amount.to_i
    end

    def representative?
      representative_or_family_type == REPRESENTATIVE_OR_FAMILY_TYPE_REPRESENTATIVE
    end

    def representative_or_family?
      [
        REPRESENTATIVE_OR_FAMILY_TYPE_REPRESENTATIVE,
        REPRESENTATIVE_OR_FAMILY_TYPE_FAMILY
      ].include?(representative_or_family_type)
    end
  end

end
