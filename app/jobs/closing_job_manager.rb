class ClosingJobManager
  include HyaccConstants
  
  def initialize(closing_status_was)
    @closing_status_was = closing_status_was
  end
  
  def perform(closing_status)
    if changed?(closing_status) && closed?(closing_status)
      ClosingJob.perform_later
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
