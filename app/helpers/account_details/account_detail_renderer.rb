module AccountDetails

  class AccountDetailRenderer
    include HyaccConst

    def initialize(account)
      @account = account
    end

    def self.get_instance(account_id)
      return nil unless account_id.to_i > 0

      account = Account.find(account_id)
      if account.path.include? ACCOUNT_CODE_SOCIAL_EXPENSE
        SocialExpenseRenderer.new(account)
      elsif account.depreciable?
        FixedAssetRenderer.new(account)
      elsif account.settlement_type_required?
        SettlementTypeRenderer.new(account)
      else
        nil
      end
    end
  end

end
