class SocialExpensesController < Base::HyaccController
  view_attribute :title => '交際費管理'
  helper_method :finder

  def index
    @journal_headers = finder.list
  end

  private

  def finder
    if @finder.nil?
      @finder = SocialExpenseFinder.new(finder_params)
      @finder.company_id = current_company.id
      @finder.fiscal_year ||= current_company.current_fiscal_year_int.to_s
      @finder.branch_id ||= current_user.employee.default_branch.id
    end

    @finder
  end

  def finder_params
    return {} unless params.include?(:finder)

    permitted = [:fiscal_year, :branch_id]
    params.require(:finder).permit(permitted)
  end

end
