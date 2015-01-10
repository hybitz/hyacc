class LedgerFinder < Base::Finder
  include JournalUtil

  def conditions_for_journals(ym = 0)
    sql = SqlBuilder.new
    sql.append('account_id = ?', account_id)
    sql.append('and branch_id = ?', branch_id) if branch_id > 0
    sql.append('and journal_details.sub_account_id = ?', sub_account_id) if sub_account_id > 0
    sql.append('and journal_headers.ym = ?', ym) if ym > 0
    sql.to_a
  end
  
  # 月別累計検索条件
  def conditions_for_monthly_summary( ym_from, ym_to )
    ret = []
    
    # 年月は必須
    if ym_from.nil? or ym_to.nil?
      raise ArgumentError.new("年月の指定がありません。")
    end
    ret[0] = "ym >= ? and ym < ? "
    ret << ym_from
    ret << ym_to

    # 勘定科目は必須
    if account_id <= 0
      raise ArgumentError.new("勘定科目の指定がありません。")
    end
    ret[0] << "and account_id = ? "
    ret << account_id
    
    # 計上部門は任意
    if branch_id > 0
      ret[0] << "and branch_id = ? "
      ret << branch_id
    end
    
    # 補助科目は任意
    if sub_account_id > 0
      ret[0] << "and sub_account_id = ? "
      ret << sub_account_id
    end

    ret
  end
  
  # 月別累計検索条件
  def conditions_for_last_year_balance( dc_type )
    ret = []
    
    # 前年度
    start_year_month = get_start_year_month_of_fiscal_year( last_year, start_month_of_fiscal_year )
    ret[0] = "ym <= ? "
    ret << get_year_months( start_year_month, 12 ).last

    # 勘定科目は必須
    if account_id <= 0
      raise ArgumentError.new("勘定科目の指定がありません。")
    end
    ret[0] << "and account_id = ? "
    ret << account_id
    
    # 貸借区分は必須
    if dc_type.to_i != DC_TYPE_DEBIT && dc_type != DC_TYPE_CREDIT
      raise ArgumentError.new("貸借区分の指定がありません。")
    end
    ret[0] << "and dc_type = ? "
    ret << dc_type

    # 計上部門は任意
    if branch_id > 0
      ret[0] << "and branch_id = ? "
      ret << branch_id
    end

    # 補助科目は任意
    if sub_account_id > 0
      ret[0] << "and sub_account_id = ? "
      ret << sub_account_id
    end

    ret
  end
  
  def last_year
    fiscal_year - 1
  end

  def get_last_year_balance
    # 科目の指定なしでは検索しない
    return nil unless account_id.to_i > 0

    account = Account.get(account_id)
    return nil if [ ACCOUNT_TYPE_PROFIT, ACCOUNT_TYPE_EXPENSE ].include? account.account_type

    debit = VMonthlyLedger.sum(:amount, conditions_for_last_year_balance(DC_TYPE_DEBIT)).to_i
    credit = VMonthlyLedger.sum(:amount, conditions_for_last_year_balance(DC_TYPE_CREDIT)).to_i

    if account.dc_type == DC_TYPE_CREDIT
      credit - debit
    else
      debit - credit
    end
  end
  
  def list
    # 科目の指定なしでは検索しない
    return [] unless account_id.to_i > 0
    
    ym_from = get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    ym_to = (ym_from / 100 + 1) * 100 + (ym_from % 100)

    ret = []
    12.times do |i|
      monthly_ledger = MonthlyLedger.new
      monthly_ledger.ym = add_months(ym_from, i)
      monthly_ledger.amount_debit = 0
      monthly_ledger.amount_credit = 0
      ret << monthly_ledger
    end
    
    # 年度内の月別累計を取得する
    conditions = conditions_for_monthly_summary( ym_from, ym_to )
    VMonthlyLedger.find_by_sql(["select ym, dc_type, sum(amount) as amount from (#{VMonthlyLedger::VIEW}) as monthly_ledger " +
      "where " + conditions.shift + "group by ym, dc_type "] + conditions).each do |ml|
        
      index = HyaccDateUtil.get_ym_index( start_month_of_fiscal_year, ml[:ym] )
      monthly_ledger = ret[index]
      monthly_ledger.ym = ml[:ym]
    
      if ml[:dc_type] == DC_TYPE_DEBIT
        monthly_ledger.amount_debit += ml[:amount]
      elsif ml[:dc_type] == DC_TYPE_CREDIT
        monthly_ledger.amount_credit += ml[:amount]
      end
    end
    
    return ret
  end

  def list_journals( ym )
    return [] unless account_id > 0
    
    ret = []
    details = JournalDetail.includes(:journal_header).references(:journal_header).select(:journal_header_id).where(conditions_for_journals(ym))
    ids = details.map(&:journal_header_id).uniq
    JournalHeader.where(:id => ids).order('ym, day, created_on').includes(:journal_details).each do |jh|
      ret << Ledger.new(jh, self)
    end
    
    ret
  end

end
