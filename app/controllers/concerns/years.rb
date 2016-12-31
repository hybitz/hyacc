module Years
  extend ActiveSupport::Concern

  included do
    helper_method :calendar_years
  end

  private

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