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
