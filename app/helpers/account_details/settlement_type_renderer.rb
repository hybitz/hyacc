module AccountDetails

  class SettlementTypeRenderer < AccountDetailRenderer
  
    def initialize( account )
      super( account )
    end

    def get_template(controller_name)
      controller_name + '/account_details/settlement_type'
    end
    
  end
  
end
