class VMonthlyLedger
  include HyaccConstants

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
    inner join journal_headers jh on (jh.id = jd.journal_header_id)
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

  # ネット累計金額を取得する
  # ym_from 累計対象となる最初の年月（inclusive）
  # ym_to 累計対象となる最後の年月（inclusive）
  def self.get_net_sum_amount(ym_from=nil, ym_to=nil, account_id=0, sub_account_id=0, branch_id=0, options = {})
    # 勘定科目は必須
    raise '勘定科目の指定がありません。' unless account_id.to_i > 0

    account = Account.find(account_id)
  
    sql = ["select sum(amount) as amount from (#{VIEW}) as monthly_ledger "]

    if options[:include_children] or not options.has_key?(:include_children)
      sql[0] << "where path like ? "
      sql << '%' + account.path + '%'
    else
      sql[0] << "where account_id = ? "
      sql << account.id
    end
    
    # 補助科目
    if sub_account_id > 0
      sql[0] << "and sub_account_id = ? "
      sql << sub_account_id
    end
    
    # 開始年月
    if ym_from.to_i > 0
      if options[:ym_from_exclusive]
        sql[0] << "and ym > ? "
      else
        sql[0] << "and ym >= ? "
      end
      sql << ym_from
    end

    # 終了年月
    if ym_to.to_i > 0
      if options[:ym_to_exclusive]
        sql[0] << "and ym < ? "
      else
        sql[0] << "and ym <= ? "
      end
    	 sql << ym_to
    end

    # 計上部門
    if branch_id > 0
      sql[0] << "and branch_id = ? "
      sql << branch_id
    end
    
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
  
end
