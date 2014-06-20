# coding: UTF-8

def details_finder
  {
    :report_type => REPORT_TYPE_WITHHOLDING_DETAILS,
    :employee_id => 1
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
