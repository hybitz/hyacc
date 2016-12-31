module Years
  extend ActiveSupport::Concern

  included do
    helper_method :calendar_years
    helper_method :fiscal_years
  end

  private

  # 会計年度選択リストを取得する
  def fiscal_years
    if @_fiscal_years.nil?
      first = current_user.company.founded_fiscal_year.fiscal_year
      last = current_user.company.fiscal_years.last.fiscal_year
      @_fiscal_years = HyaccDateUtil.get_ym_list( first, 0, last - first )
    end

    @_fiscal_years
  end
  
  # 暦年選択リストを取得する
  def calendar_years
    if @_calendar_years.nil?
      first = current_user.company.founded_fiscal_year.fiscal_year
      last = Date.today.year
      @_calendar_years = HyaccDateUtil.get_ym_list( first, 0, last - first )
    end

    @_calendar_years
  end

end