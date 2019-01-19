module AccountDetails

  class AccountDetailRenderer
    include HyaccConstants

    def initialize( account )
      @account = account
    end

    def self.get_instance( account_id )
      return nil unless account_id.to_i > 0

      account = Account.find( account_id )
      if account.path.include? ACCOUNT_CODE_SOCIAL_EXPENSE
        SocialExpenseRenderer.new( account )
      elsif account.depreciable
        FixedAssetRenderer.new( account )
      elsif account.is_corporate_tax
        SettlementTypeRenderer.new(account)
      else
        case account.code
        when ACCOUNT_CODE_CONSUMPTION_TAX_PAYABLE
          SettlementTypeRenderer.new(account)
        end
      end
    end
  end

end
