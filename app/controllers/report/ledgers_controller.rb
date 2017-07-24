class Report::LedgersController < ReportController::Base
  view_attribute :title => '元帳'
  helper_method :finder

  def index
    finder
  end
  
  private

  def finder
    if @finder.nil?
      @finder = LedgerFinder.new(finder_params)
      @finder.company_id = current_company.id
      @finder.fiscal_year ||= current_company.current_fiscal_year_int
    end

    @finder
  end

  def finder_params
    return {} unless params.include?(:finder)

    permitted = [:fiscal_year, :branch_id]
    params.require(:finder).permit(permitted)
  end

end
