もし /^月末時点での残高試算表は以下のとおり$/ do |ast_table|
  rows = normalize_table(ast_table)
  header = rows.shift
  footer = rows.pop
  assert_equal '合計', footer[1]
  joins = 'inner join accounts a on (a.id = journal_details.account_id)'

  debit_sum_amount = footer[0].gsub(',', '').to_i
  assert_equal debit_sum_amount,
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_DEBIT, DC_TYPE_DEBIT).sum(:amount) -
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_DEBIT, DC_TYPE_CREDIT).sum(:amount)
  
  credit_sum_amount = footer[2].gsub(',', '').to_i
  assert_equal credit_sum_amount,
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_CREDIT, DC_TYPE_CREDIT).sum(:amount) -
      JournalDetail.joins(joins).where('a.dc_type = ? and journal_details.dc_type = ?', DC_TYPE_CREDIT, DC_TYPE_DEBIT).sum(:amount)

  rows.each do |row|
    assert account = Account.where(:name => row[1]).first

    if account.debit?
      debit_amount = row[0].gsub(',', '').to_i
      assert_equal debit_amount,
          JournalDetail.where(:dc_type => DC_TYPE_DEBIT, :account_id => account.id).sum(:amount) -
          JournalDetail.where(:dc_type => DC_TYPE_CREDIT, :account_id => account.id).sum(:amount)
    elsif account.credit?
      credit_amount = row[2].gsub(',', '').to_i
      assert_equal credit_amount,
          JournalDetail.where(:dc_type => DC_TYPE_CREDIT, :account_id => account.id).sum(:amount) -
          JournalDetail.where(:dc_type => DC_TYPE_DEBIT, :account_id => account.id).sum(:amount)
    else
      raise "予期せぬ貸借区分\n#{account.to_yaml}"
    end
  end
end
