module JournalDate
  extend ActiveSupport::Concern

  def date
    Date.new(year, month, day.to_i)
  end
  
  def date=(value)
    self.ym = value.strftime('%Y%m').to_i
    self.day = value.day
  end

  def year
    ym.to_i / 100
  end

  def month
    ym.to_i % 100
  end

end