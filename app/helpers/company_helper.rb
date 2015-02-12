module CompanyHelper
  DEFAULT_PAYDAY = "0,25"
  
  def payday_to_jp(payday)
    payday = DEFAULT_PAYDAY if payday.blank?
    month, day = payday.split(",")
    month_jp = month + "ヶ月後"
    month_jp = month.to_i.abs.to_s + "ヶ月前" if month.to_i < 0
    case month
    when "0"
      month_jp = "当月"
    when "1"
      month_jp = "翌月"
    when "-1"
      month_jp = "前月"
    end
    
    return month_jp + day + "日"
  end

  def month_of_payday(payday)
    payday = DEFAULT_PAYDAY if payday.blank?
    month, day = payday.split(",")
    return month
  end
  
  def day_of_payday(payday)
    payday = DEFAULT_PAYDAY if payday.blank?
    month, day = payday.split(",")
    return day
  end

end
