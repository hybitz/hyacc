class WithholdingSlipFinder
  include ActiveModel::Model
  include HyaccConst
  include CalendarYearAware

  attr_accessor :report_type
  attr_accessor :company_id
  attr_accessor :employee_id

  def report_types
    types = [
      REPORT_TYPE_WITHHOLDING_SUMMARY,
      REPORT_TYPE_WITHHOLDING_DETAILS,
      REPORT_TYPE_WITHHOLDING_CALC,
    ]

    types.map{|t| NameAndValue.new(REPORT_TYPES[t], t) }
  end
end
