module Base
  class HyaccMasterController < HyaccController
    
    def index
      if finder.commit
        @list = finder.list
      end
      
      respond_to do |format|
        format.html
        format.xml  { render :xml => @list }
      end
    end
  end
end
