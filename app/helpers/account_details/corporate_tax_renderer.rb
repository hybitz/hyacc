# -*- encoding : utf-8 -*-
#
# $Id: corporate_tax_renderer.rb 2470 2011-03-23 14:58:00Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AccountDetails

  class CorporateTaxRenderer < AccountDetailRenderer
  
    def initialize( account )
      super( account )
    end

    def get_template(controller_name)
      controller_name + '/account_details/corporate_tax'
    end
    
  end
  
end
