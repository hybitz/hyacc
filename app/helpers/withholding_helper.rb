module WithholdingHelper
  def year_end(calendar_year)
    calendar_year.to_s + '/12/31'
  end
end
