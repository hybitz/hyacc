module BankAccountAware
  extend ActiveSupport::Concern

  included do
    attr_accessor :bank_account_id
  end

  def bank_account
    @bank_account ||= BankAccount.find(bank_account_id) if bank_account_id.present?
  end

end
