module Mm::DonationRecipientsHelper
  include HyaccConst
  def donation_recipient_kind_options
    labels = donation_sub_account_labels
    DONATION_RECIPIENT_SUB_ACCOUNT_CODES.map { |code| [labels[code] || code, code] }
  end

  def donation_recipient_kind_label(kind)
    code = kind.to_s
    donation_sub_account_labels[code] || code
  end

  private

  def donation_sub_account_labels
    return @donation_sub_account_labels if @donation_sub_account_labels

    account = Account.find_by(code: ACCOUNT_CODE_DONATION)
    @donation_sub_account_labels = SubAccount
      .where(account_id: account.id, code: DONATION_RECIPIENT_SUB_ACCOUNT_CODES)
      .pluck(:code, :name)
      .to_h
  end
end
