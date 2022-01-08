module SimpleSlips
  include HyaccConst

  def valid_simple_slip_params(options = {})
    account = Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)
    day = branch.company.current_fiscal_year.start_day + 2.months

    ret = {}
    ret[:ym] = day.strftime('%Y%m')
    ret[:day] = day.day.to_s
    ret[:remarks] = '簡易入力テスト'
    ret[:account_id] = account.id
    ret[:sub_account_id] = account.sub_accounts.first.id if account.has_sub_accounts?
    ret[:branch_id] = branch.id
    ret[:amount_decrease] = 1080
    ret[:tax_type] = TAX_TYPE_INCLUSIVE
    ret[:tax_rate_percent] = 8
    ret[:tax_amount_decrease] = 80
    ret[:auto_journal_type] = AUTO_JOURNAL_TYPE_ACCRUED_EXPENSE
    ret[:auto_journal_year] = ''
    ret[:auto_journal_month] = ''
    ret[:auto_journal_day] = ''
    ret[:social_expense_number_of_people] = 4

    ret
  end

end