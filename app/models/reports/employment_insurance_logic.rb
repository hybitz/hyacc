module Reports
  class EmploymentInsuranceLogic < BaseLogic
    
    def build_model
      ret = EmploymentInsuranceModel.new
      ret.start_day_estimate = start_day
      ret.end_day_estimate = end_day

      ret.fill_details( HyaccDateUtil.get_year_months(start_ym_fixed, 12))

      Payroll.joins(:employee).references(:employee).where(employees: {executive: false}).where('ym >= ? and ym <= ?', start_ym_fixed, end_ym_fixed).order(:ym).each do |p|
        if p.is_bonus?
          d = ret.get_bonus_detail(p.ym)
        else
          d = ret.get_detail(p.ym)
        end
        d.salary_total += p.salary_total
        d.employee_count += 1
      end

      ret
    end

    def start_ym
      start_ym_estimate
    end
    
    def end_ym
      end_ym_estimate
    end

    def start_ym_estimate
      @start_ym_estimate ||= "#{finder.calendar_year}04".to_i
    end

    def end_ym_estimate
      @end_ym_estimate ||= "#{finder.calendar_year.to_i + 1}03".to_i
    end

    def start_ym_fixed
      @start_ym_fixed ||= "#{finder.calendar_year.to_i - 1}04".to_i
    end
    
    def end_ym_fixed
      @end_ym_fixed ||= "#{finder.calendar_year}03".to_i
    end
  end

  class EmploymentInsuranceModel
    attr_accessor :start_day_estimate, :end_day_estimate
    attr_reader :details, :bonus_details

    def initialize
      @details = {}
      @bonus_details = {}
    end

    def fill_details(year_months)
      year_months.each do |ym|
        self.details[ym] ||= EmploymentInsuranceDetailModel.new
      end
    end

    def start_day_fixed
      start_day_estimate - 1.year
    end

    def end_day_fixed
      end_day_estimate - 1.year
    end

    def get_detail(ym)
      self.details[ym] ||= EmploymentInsuranceDetailModel.new
    end

    def get_bonus_detail(ym)
      self.bonus_details[ym] ||= EmploymentInsuranceDetailModel.new
    end

    def employee_count
      details.values.map{|d| d.employee_count }.sum
    end
  
    def salary_total
      details.values.map{|d| d.salary_total }.sum + bonus_details.values.map{|d| d.salary_total }.sum
    end
  end

  class EmploymentInsuranceDetailModel
    attr_accessor :ym
    attr_accessor :salary_total
    attr_accessor :employee_count

    def initialize
      @salary_total = 0
      @employee_count = 0
    end
  end

end
