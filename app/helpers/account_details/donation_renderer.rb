module AccountDetails
  class DonationRenderer < SubAccountDetailRenderer
    include HyaccConst

    def initialize(account, sub_account = nil)
      @account = account
      @sub_account = sub_account
    end

    def get_template(controller_name)
      "#{controller_name}/account_details/donation"
    end

    def build_locals(jd, index, company)
      sub = @sub_account || jd.sub_account
      sub_kind = sub&.code
      sub_kind ||= @account.sub_accounts.first.code
      donation_recipients = if DONATION_RECIPIENT_SUB_ACCOUNT_CODES.include?(sub_kind)
                              company.donation_recipients.where(kind: sub_kind).order(:name)
                            else
                              company.donation_recipients.where(kind: nil).order(:name)
                            end

      { jd: jd, index: index, donation_recipients: donation_recipients }
    end
  end
end
