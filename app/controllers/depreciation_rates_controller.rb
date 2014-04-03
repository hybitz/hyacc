class DepreciationRatesController < Base::BasicMasterController
  view_attribute :finder, :class=>DepreciationRateFinder, :only=>:index
  view_attribute :model, :class=>DepreciationRate
  
  def index
    @list = finder.list
    respond_to do |format|
      format.html
      format.xml  { render :xml => @list }
    end
  end
end
