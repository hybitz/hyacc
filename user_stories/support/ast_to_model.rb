module AstToModel

  def to_user(ast_table)
    table = normalize_table(ast_table)
    
    ret = User.new
    ret.login_id = table[0][1]
    ret.password = table[1][1]
    ret.email = table[2][1]
    
    e = ret.build_employee
    e.last_name = table[3][1]
    e.first_name = table[4][1]
    e.sex = SEX_TYPES.invert[table[5][1]]
    e.birth = table[6][1]
    e.employment_date = table[7][1]
    
    ret
  end

  def to_simple_slips(ast_table)
    table = normalize_table(ast_table)
    
    ret = []
    table[1..-1].each do |row|
      ret << to_simple_slip(row)
    end
    
    ret
  end

  def to_simple_slip(row)
    assert a1 = Account.where(:name => row[2], :deleted => false).first
    assert a2 = Account.where(:name => row[4], :deleted => false).first
    assert_equal row[3], row[5]

    ret = SimpleSlip.new
    ret.ym = row[0].split('-')[0..1].join
    ret.day = row[0].split('-').last
    ret.remarks = row[1]

    if a1.asset? or a1.debt?
      ret.my_account_id = a1.id
      ret.account_id = a2.id
      ret.sub_account_id = a2.sub_accounts.first.id if a2.has_sub_accounts
      ret.amount_increase = row[3].to_ai
    elsif a2.asset? or a2.debt?
      ret.my_account_id = a2.id
      ret.account_id = a1.id
      ret.sub_account_id = a1.sub_accounts.first.id if a1.has_sub_accounts
      ret.amount_decrease = row[5].to_ai
    else
      raise '簡易入力は資産か負債が対象です。'
    end
    
    ret
  end

  def to_journals(ast_table)
    ret = []

    table = normalize_table(ast_table)
    table[1..-1].each do |row|
      ret << to_journal(row)
    end

    ret
  end

  def to_journal(row)
    ret = Journal.new
    ret.ym = row[0].split('-')[0..1].join
    ret.day = row[0].split('-').last
    ret.remarks = row[1]

    jd = ret.journal_details.build
    jd.dc_type = DC_TYPE_DEBIT
    assert jd.account = Account.find_by_name(row[2])
    jd.sub_account_id = jd.account.sub_accounts.first.id if jd.account.sub_accounts.present?
    assert jd.branch = Branch.find_by_name(row[3])
    jd.input_amount = row[4].to_ai

    jd = ret.journal_details.build
    jd.dc_type = DC_TYPE_CREDIT
    assert jd.account = Account.find_by_name(row[5])
    jd.sub_account_id = jd.account.sub_accounts.first.id if jd.account.sub_accounts.present?
    assert jd.branch = Branch.find_by_name(row[6])
    jd.input_amount = row[7].to_ai
    
    ret
  end

end

World(AstToModel)
