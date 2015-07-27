class Mv::SocialInsurancesController < Base::HyaccController
  view_attribute :title => '社会保険料'
  helper_method :finder

  def index
    @list = finder.list if params[:commit]
  end

  protected

  def finder
    unless @finder
      @finder = SocialInsuranceFinder.new(params[:social_insurance_finder])
      @finder.ym = Date.today.strftime("%Y-%m") unless @finder.ym.present?
    end

    @finder
  end

end
