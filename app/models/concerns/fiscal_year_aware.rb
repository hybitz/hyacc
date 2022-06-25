module FiscalYearAware
  extend ActiveSupport::Concern

  included do
    attr_accessor :fiscal_year
  end

  def fiscal_years
    if @fiscal_years.nil?
      first = company.founded_fiscal_year.fiscal_year
      last = company.fiscal_years.order(:fiscal_year).last.fiscal_year
      @fiscal_years = HyaccDateUtil.get_ym_list(first, 0, last - first)
    end

    @fiscal_years
  end

  def ym_range
    if @ym_range.nil?
      start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year)
      @ym_range = HyaccDateUtil.get_year_months(start_year_month, 12)
    end
  
    @ym_range
  end

end