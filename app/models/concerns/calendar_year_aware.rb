module CalendarYearAware
  extend ActiveSupport::Concern

  included do
    attr_accessor :calendar_year
  end

  def employees
    ret = Employee.where(company_id: company_id, deleted: false)
    if calendar_year.present?
      ret = ret.where('employment_date <= ? and (retirement_date is null or retirement_date >= ?)', "#{calendar_year}-12-31", "#{calendar_year}-01-01")
    end
    ret
  end
end

