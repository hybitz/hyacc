class HyaccLogger
  require "date"
  
  def self.fatal?
    Rails.logger.level == Logger::FATAL
  end

  def self.fatal(message, e=nil)
    Rails.logger.fatal("[FATAL: #{current_time} #{called_by}] #{message}")
    if e and e.is_a? Exception
      e.backtrace.each do |trace|
        Rails.logger.fatal trace
      end
    end
  end

  def self.error?
    fatal? or Rails.logger.level == Logger::ERROR
  end

  def self.error(message, e=nil)
    Rails.logger.error("[ERROR: #{current_time} #{called_by}] #{message}")
    if e and e.is_a? Exception
      e.backtrace.each do |trace|
        Rails.logger.error trace
      end
    end
  end

  def self.warn?
    error? or Rails.logger.level == Logger::WARN
  end

  def self.warn(message, e=nil)
    Rails.logger.warn("[WARN: #{current_time} #{called_by}] #{message}")
    if e and e.is_a? Exception
      e.backtrace.each do |trace|
        Rails.logger.warn trace
      end
    end
  end

  def self.info?
    warn? or Rails.logger.level == Logger::INFO
  end

  def self.info(message)
    Rails.logger.info("[INFO: #{current_time} #{called_by}] #{message}")
  end

  def self.debug?
    info? or Rails.logger.level == Logger::DEBUG
  end
  
  def self.debug(message)
    Rails.logger.debug("[DEBUG: #{current_time} #{called_by}] #{message}")
  end
  
  private

  def self.current_time
    Time.new.strftime("%Y-%m-%d %H:%M:%S")
  end
  
  def self.called_by
    caller[1]
  end

end
