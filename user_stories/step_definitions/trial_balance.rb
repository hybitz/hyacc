もし /^現時点での残高試算表は以下のとおり$/ do |ast_table|
  rows = normalize_table(ast_table)
  header = rows.shift
  footer = rows.pop
  assert_equal '合計', footer[1]
  joins = 'inner join accounts a on (a.id = journal_details.account_id)'

  rows.each do |row|
    begin
      assert_equal 1, Account.where(:name => row[1]).size
    rescue => e
      raise "勘定科目 #{row[1]} がみつかりませんでした。"
    end

    assert account = Account.where(:name => row[1]).first

    if account.debit?
      expected = row[0].to_ai
      debit_amount = JournalDetail.where(:dc_type => DC_TYPE_DEBIT, :account_id => account.id).sum(:amount) -
          JournalDetail.where(:dc_type => DC_TYPE_CREDIT, :account_id => account.id).sum(:amount)
      assert debit_amount == expected, "#{account.name} の金額 #{debit_amount} が #{expected} と一致しません。"
    elsif account.credit?
      expected = row[2].to_ai
      credit_amount = JournalDetail.where(:dc_type => DC_TYPE_CREDIT, :account_id => account.id).sum(:amount) -
          JournalDetail.where(:dc_type => DC_TYPE_DEBIT, :account_id => account.id).sum(:amount)
      assert credit_amount == expected, "#{account.name} の金額 #{credit_amount} が #{expected} と一致しません。"
    else
      raise "予期せぬ貸借区分\n#{account.to_yaml}"
    end
  end

  accounts = rows.map{|row| Account.where(:name => row[1]).first }
  details = JournalDetail.where('account_id not in (?)', accounts.map(&:id))
  assert details.empty?, "予期せぬ勘定科目の仕訳が存在します。#{details.to_yaml}"

  debit_sum_amount = footer[0].to_ai
  expected = JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_DEBIT, DC_TYPE_DEBIT).sum(:amount) -
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_DEBIT, DC_TYPE_CREDIT).sum(:amount)
  assert debit_sum_amount == expected, "借方合計金額 #{expected} が #{debit_sum_amount} と一致しません。"
  
  credit_sum_amount = footer[2].to_ai
  expected = JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_CREDIT, DC_TYPE_CREDIT).sum(:amount) -
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_CREDIT, DC_TYPE_DEBIT).sum(:amount)
  assert credit_sum_amount == expected, "貸方合計金額 #{expected} が #{credit_sum_amount} と一致しません。"
end
