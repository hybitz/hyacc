class DepreciationRatesController < Base::BasicMasterController
  view_attribute :finder, :class=>DepreciationRateFinder, :only=>:index
  
  def index
    @list = finder.list
    respond_to do |format|
      format.html
      format.xml  { render :xml => @list }
    end
  end
end
