module Accounts
  include HyaccConstants

  def expense_account
    @_expense_account ||= Account.where(:account_type => ACCOUNT_TYPE_EXPENSE, :journalizable => true).not_deleted.first
  end
  
  def social_expense_account
    @_social_expense_account ||= Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)
  end
  
  def valid_account_params
    {
      :code => '9999',
      :name => 'test',
      :dc_type => DC_TYPE_DEBIT,
      :account_type => ACCOUNT_TYPE_ASSET,
      :tax_type => TAX_TYPE_NONTAXABLE
    }
  end
end
