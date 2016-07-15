class ClosingJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    
  end
end
