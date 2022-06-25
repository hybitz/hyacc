class Hr::SocialInsurancesController < ApplicationController
  helper_method :finder

  def index
    @payrolls_by_employee = finder.list_payrolls_by_employee
  end

  private

  def finder
    unless @finder
      @finder = SocialInsuranceFinder.new(finder_params)
      @finder.company_id ||= current_company.id
      @finder.fiscal_year ||= current_company.fiscal_year
    end
    
    @finder
  end

  def finder_params
    if params[:finder].present?
      params.require(:finder).permit(:fiscal_year)
    else
      {}
    end
  end

end
