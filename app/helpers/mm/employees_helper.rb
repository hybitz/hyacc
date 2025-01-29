module Mm::EmployeesHelper
  
  def render_duration(year, month)
    ret = ''
    
    if year > 0
      ret << year.to_s << "年"
    end
    
    if month > 0
      ret << month.to_s << "ヶ月"
    end
    
    ret = '1ヶ月' if ret.blank?
    ret
  end

  def get_start_ym_of_retirement_savings(employee)
    rsa = employee.company.retirement_savings_after
    return nil unless rsa
    employee.employment_date.years_since(rsa - 1).strftime("%Y年%-m月")
  end

end
