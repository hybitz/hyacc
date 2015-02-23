module Reports
  class WithholdingCalcLogic < BaseLogic
    def get_withholding_info
      model = WithholdingCalc.new
      model.calendar_year = @finder.calendar_year
      model
    end
  end
end
