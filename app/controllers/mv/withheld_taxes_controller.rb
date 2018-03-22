class Mv::WithheldTaxesController < Base::HyaccController
  helper_method :finder

  def index
    @list = finder.list if params[:commit]
  end

  protected

  def finder
    unless @finder
      @finder = WithheldTaxFinder.new(finder_params)
      @finder.ym = Date.today.strftime("%Y-%m") unless @finder.ym.present?
    end

    @finder
  end
  
  def finder_params
    if params[:withheld_tax_finder]
      params.require(:withheld_tax_finder).permit(
          :ym
        )
    end
  end

end
