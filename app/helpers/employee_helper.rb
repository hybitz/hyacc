# -*- encoding : utf-8 -*-
module EmployeeHelper
  
  def render_duration(year, month)
    ret = ""
    
    if year > 0
      ret << year.to_s << "年"
    end
    
    if month > 0
      ret << month.to_s << "ヶ月"
    end
    
    if ret.size == 0
      ret << "1ヶ月"
    end
  
    ret
  end
end
