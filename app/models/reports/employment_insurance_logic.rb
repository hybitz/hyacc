module Reports
  class EmploymentInsuranceLogic < BaseLogic
    
    def build_model
      ret = EmploymentInsuranceModel.new
      ret.start_day_estimate = start_day
      ret.end_day_estimate = end_day
      ret
    end

    def start_ym
      @start_ym ||= "#{finder.calendar_year}04"
    end
    
    def end_ym
      @end_ym ||= "#{finder.calendar_year.to_i + 1}03"
    end

  end

  class EmploymentInsuranceModel
    attr_accessor :start_day_estimate, :end_day_estimate

    def start_day_fixed
      start_day_estimate - 1.year
    end

    def end_day_fixed
      end_day_estimate - 1.year
    end
  end
  

end
