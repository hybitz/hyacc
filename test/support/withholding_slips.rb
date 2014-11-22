module WithholdingSlips
  include HyaccConstants

  def details_finder
    {
      :report_type => REPORT_TYPE_WITHHOLDING_DETAILS,
      :employee_id => 1,
      :calendar_year => 2008
    }
  end
  
  def summary_finder
    {
      :report_type => REPORT_TYPE_WITHHOLDING_SUMMARY,
      :employee_id => 1
    }
  end
  
  def no_employee_finder
    {
      :report_type => REPORT_TYPE_WITHHOLDING_DETAILS
    }
  end

  def no_exemption_details_finder
    {
      :report_type => REPORT_TYPE_WITHHOLDING_DETAILS,
      :employee_id => 1,
      :calendar_year => 2014
    }
  end
end