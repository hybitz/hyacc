class Mv::DepreciationRatesController < Base::HyaccController
  helper_method :finder
  
  def index
    @list = finder.list
    respond_to do |format|
      format.html
      format.xml  { render :xml => @list }
    end
  end

  private

  def finder
    unless @finder
      @finder = DepreciationRateFinder.new(finder_params)
    end
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit()
    end
  end
end
