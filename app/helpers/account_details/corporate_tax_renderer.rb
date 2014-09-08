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
