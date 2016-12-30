module YmdInputState
  extend ActiveSupport::Concern

  protected

  def ymd_input_state
    ymd = session[:ymd_input_state]

    if ymd.nil?
      today = Date.today
      ymd = Slips::YmdInputState.new
      ymd.ym = today.strftime("%Y%m")
      ymd.day = today.strftime("%d")
      session[:ymd_input_state] = ymd
    end

    ymd
  end

end