module AccountDetails

  class SubAccountDetailRenderer
    include HyaccConst

    def self.get_instance(account_id, sub_account_id = nil)
      return nil unless account_id.to_i > 0

      account = Account.find(account_id)
      return nil unless account.path.include?(ACCOUNT_CODE_DONATION)

      sub_account = nil
      sub_account = account.get_sub_account_by_id(sub_account_id.to_i) if sub_account_id.present?

      DonationRenderer.new(account, sub_account)
    end
  end

end
