module NotificationHelper
  
  def get_debt_count(debts, include_closed=false)
    return debts.size if include_closed
    return debts.select{|debt| debt.closed_id.nil? }.size
  end

end
