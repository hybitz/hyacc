class DepreciationRatesController < Base::BasicMasterController
  view_attribute :title => '減価償却率'
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
      @finder = DepreciationRateFinder.new(params[:finder])
    end
    @finder
  end
end
