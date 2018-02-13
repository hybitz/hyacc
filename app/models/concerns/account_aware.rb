module AccountAware
  extend ActiveSupport::Concern

  included do
    attr_accessor :account_id
  end

  def account
    @account ||= Account.find(account_id) if account_id.present?
  end

  def accounts
    @accounts ||= Account.get_journalizable_accounts
  end

end