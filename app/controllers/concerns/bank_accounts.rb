module BankAccounts
  extend ActiveSupport::Concern

  included do
    helper_method :bank_accounts
    helper_method :securities_accounts
  end

  private

  def bank_accounts
    @bank_accounts ||= BankAccount.where(deleted: false).order(:name)
  end

  def securities_accounts
    types = [
      BankAccount::FINANCIAL_ACCOUNT_TYPE_GENERAL,
      BankAccount::FINANCIAL_ACCOUNT_TYPE_SPECIFIC,
      BankAccount::FINANCIAL_ACCOUNT_TYPE_SPECIFIC_WITHHOLD
    ]
    @securities_accounts ||= BankAccount.where(financial_account_type: types, deleted: false).order(:name)
  end

end
