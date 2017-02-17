require "colorable"

class NotificationsController < Base::HyaccController
  include Colorable

  def index
    begin
      @events = get_events if current_user.has_google_account
    rescue => e
      handle(e)
    end
    
    respond_to do |format|
      format.html { render :layout => ! request.xhr? }
      format.json { render :json => events_as_json(@events) }
    end
  end

  private

  def events_as_json(events)
    ret = []

    events.each do |e|
      hash = {}
      hash[:title] = e.title
      hash[:allDay] = e.allday
      hash[:start] = e.st.localtime
      hash[:end] = e.en.localtime unless e.allday
      hash[:backgroundColor] = next_color(e.who)
      ret << hash
    end if events.present?

    ret.to_json
  end

  def next_color(who)
    @colors ||= {}
    ret = @colors[who]

    unless ret
      @color ||= Color.new :blanched_almond
      @color = @color.next
      until @color.dark?
        @color = @color.next
      end
      ret = @colors[who] = @color
    end

    ret.hex
  end

  def get_events
    return [] if true # GoogleClientAPI待ち
    ret = []
    get_calendars.each_value do |c|
      c.events(:singleevents => true,
          "start-min" => Time.at(params[:start].to_i).strftime('%Y-%m-%dT00:00:00'),
          "start-max" => Time.at(params[:end].to_i).strftime('%Y-%m-%dT00:00:00'),
          "recurrence-expansion-start" => Time.at(params[:start].to_i).strftime('%Y-%m-%dT00:00:00'),
          "recurrence-expansion-end" => Time.at(params[:end].to_i).strftime('%Y-%m-%dT00:00:00')).each do |e|
        ret << e
      end
    end
    ret.sort{|a,b| a.st <=> b.st}
  end

  def get_calendars
    # TODO
    #GoogleCalendar::Calendar.calendars(google_service)
  end

  def google_service
    # TODO
    #session[:google_service] ||= GoogleCalendar::Service.new(current_user.google_account, current_user.google_password)
  end
end
