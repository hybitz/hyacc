require 'googlecalendar/service'
require 'googlecalendar/event'
require 'time'

module GoogleCalendar

  class Calendar
    def self.calendars(srv)
      ret = srv.calendar_list
      Rails.logger.debug ret.to_yaml
      list = REXML::Document.new(ret.body)
      h = {}
      list.root.elements.each("entry/link") do |e|
        if e.attributes["rel"] == "alternate"
          feed = e.attributes["href"]
          h[feed] = Calendar.new(srv, feed)
        end
      end
      h
    end
  end

  class Event
    attr_accessor :id, :who, :recurrence
    ATTRIBUTES_MAP["id"] = {"element" => "id"}
    ATTRIBUTES_MAP["who"] = {"element" => "gd:who", "attribute" => "valueString"}
    ATTRIBUTES_MAP["recurrence"] = { "element" => "gd:recurrence", "from_xml" => "handle_recurrence"}

    def handle_recurrence(str)
      true
    end
  end

end
