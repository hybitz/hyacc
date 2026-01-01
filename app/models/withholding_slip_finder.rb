class WithholdingSlipFinder
  include ActiveModel::Model
  include HyaccConst

  attr_accessor :report_type
  attr_accessor :company_id
  attr_accessor :calendar_year
  attr_accessor :employee_id

  def employees
    ret = Employee.where(company_id: company_id, deleted: false)
    if calendar_year.present?
      ret = ret.where('employment_date <= ? and (retirement_date is null or retirement_date >= ?)', "#{calendar_year}-12-31", "#{calendar_year}-01-01")
    end
    ret
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
