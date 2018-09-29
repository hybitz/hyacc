もし /^現時点での残高試算表は以下のとおり$/ do |ast_table|
  rows = normalize_table(ast_table)
  header = rows.shift
  footer = rows.pop
  assert_equal '合計', footer[1]
  joins = 'inner join accounts a on (a.id = journal_details.account_id)'

  errors = []
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
      errors << "#{account.name} の金額 #{debit_amount} は #{expected} と #{debit_amount - expected} 差異があります。" if debit_amount != expected
    elsif account.credit?
      expected = row[2].to_ai
      credit_amount = JournalDetail.where(:dc_type => DC_TYPE_CREDIT, :account_id => account.id).sum(:amount) -
          JournalDetail.where(:dc_type => DC_TYPE_DEBIT, :account_id => account.id).sum(:amount)
      errors << "#{account.name} の金額 #{credit_amount} は #{expected} と #{credit_amount - expected} 差異があります。" if credit_amount != expected
    else
      raise "予期せぬ貸借区分\n#{account.attributes.to_yaml}"
    end
  end

  accounts = rows.map{|row| Account.where(:name => row[1]).first }
  details = JournalDetail.where('account_id not in (?)', accounts.map(&:id))
  assert details.empty?, "予期せぬ勘定科目の仕訳が存在します。#{details.map(&:attributes).to_yaml}"

  expected = footer[0].to_ai
  debit_sum_amount = JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_DEBIT, DC_TYPE_DEBIT).sum(:amount) -
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_DEBIT, DC_TYPE_CREDIT).sum(:amount)
  errors << "借方合計金額 #{debit_sum_amount} は #{expected} と #{debit_sum_amount - expected} 差異があります。" if debit_sum_amount != expected
  
  expected = footer[2].to_ai
  credit_sum_amount = JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_CREDIT, DC_TYPE_CREDIT).sum(:amount) -
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_CREDIT, DC_TYPE_DEBIT).sum(:amount)
  errors << "貸方合計金額 #{credit_sum_amount} は #{expected} と #{credit_sum_amount - expected} 差異があります。" if credit_sum_amount != expected
  
  assert errors.empty?, errors.join("\n")
end
