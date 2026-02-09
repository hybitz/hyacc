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
