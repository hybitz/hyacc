# -*- encoding : utf-8 -*-
#
# $Id: social_expense_renderer.rb 2470 2011-03-23 14:58:00Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AccountDetails

  class SocialExpenseRenderer < AccountDetailRenderer
  
    def initialize( account )
      super( account )
    end

    def get_template(controller_name)
      controller_name + '/account_details/social_expense'
    end
    
  end
  
end
