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
      elsif account.path.include? ACCOUNT_CODE_SECURITIES
        InvestmentRenderer.new(account)
      else
        nil
      end
    end
  end

end
