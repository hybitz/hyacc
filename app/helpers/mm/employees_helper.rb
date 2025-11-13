module Mm::EmployeesHelper
  
  def render_duration(year, month)
    parts = []
    
    if year > 0
      parts << "#{year}年"
    end
    
    if month > 0
      parts << "#{month}ヶ月"
    end
    
    parts.empty? ? '1ヶ月' : parts.join
  end

  def get_start_ym_of_retirement_savings(employee)
    rsa = employee.company.retirement_savings_after
    return nil unless rsa
    employee.employment_date.years_since(rsa - 1).strftime("%Y年%-m月")
  end

end
