class ClosingJobManager
  include HyaccConstants
  
  def initialize(fiscal_year)
    @fiscal_year = fiscal_year
    @closing_status_was = fiscal_year.closing_status
  end
  
  def perform(closing_status)
    if changed?(closing_status) && closed?(closing_status)
      #ClosingAccountJob.perform_later(@fiscal_year)
    end
  end
  
  private
  
  def changed?(closing_status)
    return @closing_status_was.to_i != closing_status.to_i
  end
  
  def closed?(closing_status)
    return CLOSING_STATUS_CLOSED == closing_status.to_i
  end
end
