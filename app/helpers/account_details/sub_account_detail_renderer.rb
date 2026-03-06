module AccountDetails

  class SubAccountDetailRenderer
    include HyaccConst

    def self.get_instance(account_id, sub_account_id = nil)
      return nil unless account_id.to_i > 0

      account = Account.find(account_id)

      if sub_account_id.present?
        sub_account = account.get_sub_account_by_id(sub_account_id.to_i)
        return nil unless sub_account
      end

      DonationRenderer.new(account)
    end
  end

end
