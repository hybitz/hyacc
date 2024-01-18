class SocialExpensesController < Base::HyaccController
  helper_method :finder

  def index
    @journals = finder.list
    @social_expense_logic = Reports::SocialExpenseLogic.new(finder)
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
