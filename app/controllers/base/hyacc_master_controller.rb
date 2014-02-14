# coding: UTF-8
#
# $Id: hyacc_master_controller.rb 2957 2012-11-09 07:45:31Z ichy $
# Product: hyacc
# Copyright 2009-2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#

module Base
  class HyaccMasterController < HyaccController
    
    # GET /model_classes
    # GET /model_classes.xml
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
