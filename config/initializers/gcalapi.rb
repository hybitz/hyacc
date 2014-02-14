# -*- encoding : utf-8 -*-
require 'googlecalendar/service'
require 'googlecalendar/event'
require 'time'

module GoogleCalendar
  class Service
  private 
    def auth
      https = Net::HTTP.new(AUTH_SERVER, 443, @@proxy_addr, @@proxy_port, @@proxy_user, @@proxy_pass)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      head = {'Content-Type' => 'application/x-www-form-urlencoded'}
      logger.info "-- auth st --" if logger
      https.start do |w|
        res = w.post(AUTH_PATH, "Email=#{@email}&Passwd=#{CGI.escape(@pass)}&source=company-app-1&service=cl&accountType=HOSTED", head)
        logger.debug res if logger
        if res.body =~ /Auth=(.+)/
          @auth = $1 
        else
          if logger
            logger.fatal(res)
            logger.fatal(res.body)
          end
          raise AuthenticationFailed
        end
      end
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
