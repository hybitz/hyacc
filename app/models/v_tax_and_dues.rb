class VTaxAndDues
  include HyaccConstants
  
  VIEW = <<EOS
    select
      jh.company_id,
      jh.ym,
      jd.dc_type,
      jd.account_id,
      a.path,
      jd.sub_account_id,
      jd.branch_id,
      jd.settlement_type,
      sum(jd.amount) as amount
    from journal_details jd
    inner join journals jh on (jh.id = jd.journal_id)
    inner join accounts a on (a.id = jd.account_id)
    group by jh.company_id, jh.ym, jd.dc_type, jd.account_id, jd.sub_account_id, jd.branch_id, jd.settlement_type
EOS

  # 指定年月までのネット累計金額を取得する
  # ym 累計対象となる最後の年月（exclusive）
  def self.net_sum_until(ym, account_id, sub_account_id=0, branch_id=0, include_children=true)
    self.net_sum(nil, HyaccDateUtil.last_month(ym), 0, account_id, sub_account_id, branch_id, include_children)
  end
  
  # ネット累計金額を取得する
  # ym_from 累計対象となる最初の年月（inclusive）
  # ym_to 累計対象となる最後の年月（inclusive）
  def self.net_sum(ym_from, ym_to, settlement_type, account_id, sub_account_id=0, branch_id=0, include_children=true)
    # 勘定科目は必須
    raise ArgumentError.new("勘定科目の指定がありません。") unless account_id > 0

    account = Account.find(account_id)
  
    sql = ["select sum(amount) as amount from (#{VIEW}) as tax "]
    
    # 下位の勘定科目を含める場合
    if include_children
      sql[0] << "where path like ? "
      sql << '%' + account.path + '%'
    # 含めない場合
    else
      sql[0] << "where account_id = ? "
      sql << account.id
    end
    
    # 決算区分
    if settlement_type > 0
      sql[0] << "and settlement_type = ? "
      sql << settlement_type
    end
    
    # 補助科目
    if sub_account_id > 0
      sql[0] << "and sub_account_id = ? "
      sql << sub_account_id
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
