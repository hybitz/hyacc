class WithholdingSlipFinder
  include ActiveModel::Model
  include HyaccConstants

  attr_accessor :report_type
  attr_accessor :company_id
  attr_accessor :calendar_year
  attr_accessor :employee_id

  def employee_id_enabled?
    true
  end

  def calendar_year_options
    {}
  end

  def report_types
    types = [
      REPORT_TYPE_WITHHOLDING_SUMMARY,
      REPORT_TYPE_WITHHOLDING_DETAILS,
      REPORT_TYPE_WITHHOLDING_CALC,
    ]

    types.map{|t| NameAndValue.new(REPORT_TYPES[t], t) }
  end
end
