class NotificationsController < Base::HyaccController
  require 'uri'
  require 'gcalapi'
  require 'googlecalendar/auth_sub_util'
  require 'googlecalendar/service_auth_sub'
  require 'googlecalendar/calendar'

  def index
    begin
      @events = get_events if current_user.has_google_account
    rescue => e
      handle(e)
    end
    
    render :layout => ! request.xhr?
  end

  private

  def get_events
    now = Time.now
    
    ret = []
    get_calendars.each_value do |c|
      c.events(:singleevents => true,
          "start-min" => now.strftime('%Y-%m-%dT00:00:00'),
          "start-max" => (now + 1.month).strftime('%Y-%m-%dT00:00:00'),
          "recurrence-expansion-start" => now.strftime('%Y-%m-%dT00:00:00'),
          "recurrence-expansion-end" => (now + 1.month).strftime('%Y-%m-%dT00:00:00')).each do |e|
        ret << e
      end
    end
    ret.sort{|a,b| a.st <=> b.st}
  end

  def get_calendars
    GoogleCalendar::Calendar.calendars(google_service)
  end

  def google_service
    session[:google_service] ||= GoogleCalendar::Service.new(current_user.google_account, current_user.google_password)
  end
end
