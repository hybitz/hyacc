module Accounts
  include HyaccConstants

  def account
    @_account ||= Account.not_deleted.first
  end
  
  def deleted_account
    @_deleted_account ||= Account.where(:deleted => true).first
  end

  def expense_account
    if @_expense_account.nil?
      assert @_expense_account = Account.expenses.where(:sub_account_type => SUB_ACCOUNT_TYPE_NORMAL, :journalizable => true).not_deleted.first
      assert @_expense_account.sub_accounts.empty?
    end

    @_expense_account
  end
  
  def social_expense_account
    @_social_expense_account ||= Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)
  end
  
  def valid_account_params
    {
      :code => '9999',
      :name => time_string,
      :dc_type => DC_TYPE_DEBIT,
      :account_type => ACCOUNT_TYPE_ASSET,
      :tax_type => TAX_TYPE_NONTAXABLE
    }
  end

  def invalid_account_params
    {
      :code => '9999',
      :name => '',
      :dc_type => DC_TYPE_DEBIT,
      :account_type => ACCOUNT_TYPE_ASSET,
      :tax_type => TAX_TYPE_NONTAXABLE
    }
  end

end
