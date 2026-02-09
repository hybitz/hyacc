class VMonthlyLedger
  include HyaccConst

  VIEW = <<EOS
    select
      jh.company_id,
      jh.ym,
      jd.dc_type,
      jd.account_id,
      a.sub_account_type,
      a.path,
      jd.sub_account_id,
      jd.branch_id,
      sum(jd.amount) as amount
    from journal_details jd
    inner join journals jh on (jh.id = jd.journal_id)
    inner join accounts a on (a.id = jd.account_id)
    group by jh.company_id, jh.ym, jd.dc_type, jd.account_id, jd.sub_account_id, jd.branch_id
EOS

  def self.find_by_sql(args)
    JournalDetail.find_by_sql(args)
  end
  
  def self.where(conditions)
    sql = ["select * from (#{VIEW}) as monthly_ledger where #{conditions[0]} "] + conditions[1..-1]
    find_by_sql(sql)
  end

  def self.sum(column, conditions)
    sql = ["select sum(#{column}) as #{column} from (#{VIEW}) as monthly_ledger where #{conditions[0]} "] + conditions[1..-1]
    find_by_sql(sql)[0].__send__(column)
  end

  def self.term_net_sums_by_branch(ym_from, ym_to, company, account, sub_account: nil)
    sql = SqlBuilder.new
    sql.append("select branch_id, dc_type, sum(amount) as amount from (#{VIEW}) as monthly_ledger")
    sql.append('where company_id = ?', company.id)
    sql.append('  and ym >= ?', ym_from)
    sql.append('  and ym <= ?', ym_to)
    sql.append('  and account_id = ? ', account.id)
    sql.append('  and sub_account_id = ?', sub_account.id) if sub_account
    sql.append('group by branch_id, dc_type')

    sums = find_by_sql(sql.to_a)
  
    ret = {}
    sums.each do |sum|
      ret[sum.branch_id] ||= 0
      if sum.dc_type == account.dc_type
        ret[sum.branch_id] += sum.amount
      else
        ret[sum.branch_id] -= sum.amount
      end
    end
  
    ret
  end

  # ネット累計金額を取得する
  def self.net_sum(ym_from, ym_to, account_id, sub_account_id=nil, branch_id=nil, options={})
    # 勘定科目は必須
    raise '勘定科目の指定がありません。' unless account_id.to_i > 0

    account = Account.find(account_id)
    sql = make_condition(ym_from, ym_to, account, sub_account_id, branch_id, **options)
    
    # 貸借区分用の条件文を用意
    sql[0] << "and dc_type = ? "

    # 借方合計
    sql << DC_TYPE_DEBIT
    amount_debit = JournalDetail.find_by_sql(sql)[0].amount.to_i

    # 貸方合計
    sql[-1] = DC_TYPE_CREDIT
    amount_credit = JournalDetail.find_by_sql(sql)[0].amount.to_i
    
    if account.dc_type == DC_TYPE_DEBIT
      amount_debit - amount_credit
    else
      amount_credit - amount_debit
    end
  end
  
  # 借方合計金額を取得する
  def self.get_debit_sum_amount(ym_from, ym_to, account_id, sub_account_id=nil, branch_id=nil, options={})
    # 勘定科目は必須
    raise '勘定科目の指定がありません。' unless account_id.to_i > 0
  
    account = Account.find(account_id)
    sql = make_condition(ym_from, ym_to, account, sub_account_id, branch_id, **options)
    
    # 借方合計
    sql[0] << "and dc_type = ? "
    sql << DC_TYPE_DEBIT
    JournalDetail.find_by_sql(sql)[0].amount.to_i
  end

  # 貸方合計金額を取得する
  def self.get_credit_sum_amount(ym_from, ym_to, account_id, sub_account_id=nil, branch_id=nil, options={})
    # 勘定科目は必須
    raise '勘定科目の指定がありません。' unless account_id.to_i > 0
  
    account = Account.find(account_id)
    sql = make_condition(ym_from, ym_to, account, sub_account_id, branch_id, **options)
    
    # 貸方合計
    sql[0] << "and dc_type = ? "
    sql << DC_TYPE_CREDIT
    JournalDetail.find_by_sql(sql)[0].amount.to_i
  end

  def self.make_condition(ym_from, ym_to, account, sub_account_id, branch_id, include_children: true)
    sql = ["select sum(amount) as amount from (#{VIEW}) as monthly_ledger "]

    if include_children
      sql[0] << "where path like ? "
      sql << '%' + account.path + '%'
    else
      sql[0] << "where account_id = ? "
      sql << account.id
    end
    
    # 補助科目
    case sub_account_id
    when Array
      if sub_account_id.present?
        sql[0] << 'and sub_account_id in(?)  '
        sql << sub_account_id
      end
    else
      if sub_account_id.to_i > 0
        sql[0] << 'and sub_account_id = ? '
        sql << sub_account_id
    end
    end
    
    # 開始年月
    if ym_from.to_i > 0
      sql[0] << "and ym >= ? "
      sql << ym_from
    end

    # 終了年月
    if ym_to.to_i > 0
      sql[0] << "and ym <= ? "
      sql << ym_to
    end

    # 計上部門
    if branch_id.to_i > 0
      sql[0] << "and branch_id = ? "
      sql << branch_id
    end
    
    sql
  end
  private_class_method :make_condition

end
