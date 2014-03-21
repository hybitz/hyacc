module EmployeesHelper
  
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
end
