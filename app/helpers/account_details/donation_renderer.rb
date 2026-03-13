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
      show_select = DONATION_RECIPIENT_SUB_ACCOUNT_CODES.include?(sub_kind)
      donation_recipients = show_select ? company.donation_recipients.where(kind: sub_kind).order(:name) : []

      { jd: jd, index: index, show_select: show_select, donation_recipients: donation_recipients }
    end
  end
end
