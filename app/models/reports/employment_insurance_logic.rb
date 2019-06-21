module Reports
  class EmploymentInsuranceLogic < BaseLogic
    
    def build_model
      ret = EmploymentInsuranceModel.new
      ret.start_day = start_day
      ret.end_day = end_day
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
    attr_accessor :start_day, :end_day
  end
  

end
