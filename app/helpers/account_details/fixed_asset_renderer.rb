# -*- encoding : utf-8 -*-
#
# $Id: fixed_asset_renderer.rb 2470 2011-03-23 14:58:00Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AccountDetails

  class FixedAssetRenderer < AccountDetailRenderer
  
    def initialize( account )
      super( account )
    end

    def get_template(controller_name)
      controller_name + '/account_details/fixed_asset'
    end
    
  end
  
end
