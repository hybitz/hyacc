class Mv::SocialInsurancesController < Base::HyaccController
  view_attribute :title => '社会保険料'
  helper_method :finder

  def index
    @list = finder.list if params[:commit]
  end

  private

  def finder
    unless @finder
      @finder = SocialInsuranceFinder.new(finder_params)
      @finder.ym ||= Date.today.strftime("%Y-%m")
      @finder.prefecture_code ||= current_company.head_branch.business_office.prefecture_code
    end

    @finder
  end

  def finder_params
    if params[:social_insurance_finder].present?
      params.require(:social_insurance_finder).permit(:ym, :prefecture_code, :base_salary)
    else
      {}
    end
  end
end
