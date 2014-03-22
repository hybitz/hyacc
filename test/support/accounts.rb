def expense_account
  @_expense_account ||= Account.where(:account_type => ACCOUNT_TYPE_EXPENSE, :journalizable => true).not_deleted.first
end
