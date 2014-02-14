# coding: UTF-8
#
# $Id: account_detail_renderer.rb 3333 2014-01-30 14:18:42Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AccountDetails

  class AccountDetailRenderer
    include HyaccConstants
    
    def initialize( account )
      @account = account
    end
    
    def self.get_instance( account_id )
      return nil unless account_id.to_i > 0
      
      account = Account.get( account_id )
      if account.path.include? ACCOUNT_CODE_SOCIAL_EXPENSE
        SocialExpenseRenderer.new( account )
      elsif account.depreciable
        FixedAssetRenderer.new( account )
      elsif account.is_corporate_tax
        CorporateTaxRenderer.new( account )
      else
        nil
      end
    end
  end

end
