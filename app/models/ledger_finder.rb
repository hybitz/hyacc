class LedgerFinder < Daddy::Model
  include JournalUtil

  def conditions_for_journals(ym = 0)
    sql = SqlBuilder.new
    sql.append('account_id = ?', account_id)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and journal_details.sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0
    sql.append('and journal_headers.ym = ?', ym) if ym > 0
    sql.to_a
  end
  
  # 月別累計検索条件
  def conditions_for_monthly_summary(ym_from, ym_to)
    raise ArgumentError.new("年月の指定がありません。") unless ym_from and ym_to
    raise ArgumentError.new("勘定科目の指定がありません。") unless account_id.to_i > 0

    sql = SqlBuilder.new
    sql.append('ym >= ? and ym < ?', ym_from, ym_to)
    sql.append('and account_id = ?', account_id)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0

    sql.to_a
  end
  
  # 月別累計検索条件
  def conditions_for_last_year_balance( dc_type )
    raise ArgumentError.new("勘定科目の指定がありません。") unless account_id.to_i > 0
    raise ArgumentError.new("貸借区分の指定がありません。") unless [DC_TYPE_DEBIT, DC_TYPE_CREDIT].include?(dc_type)

    # 前年度末
    start_year_month = get_start_year_month_of_fiscal_year(last_year, start_month_of_fiscal_year)

    sql = SqlBuilder.new
    sql.append('ym <= ?', get_year_months( start_year_month, 12 ).last)
    sql.append('and account_id = ?', account_id)
    sql.append('and dc_type = ?', dc_type)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0

    sql.to_a
  end
  
  def last_year
    fiscal_year.to_i - 1
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

    ret = {}
    12.times do |i|
      ym = add_months(ym_from, i)

      ml = MonthlyLedger.new
      ml.ym = ym
      ml.amount_debit = 0
      ml.amount_credit = 0
      ret[ym] = ml
    end
    
    # 年度内の月別累計を取得する
    conditions = conditions_for_monthly_summary(ym_from, ym_to)
    VMonthlyLedger.find_by_sql(["select ym, dc_type, sum(amount) as amount from (#{VMonthlyLedger::VIEW}) as ml " +
      "where " + conditions.shift + " group by ym, dc_type"] + conditions).each do |hash|
        
      ml = ret[hash[:ym]]

      if hash[:dc_type] == DC_TYPE_DEBIT
        ml.amount_debit += hash[:amount]
      elsif hash[:dc_type] == DC_TYPE_CREDIT
        ml.amount_credit += hash[:amount]
      else
        raise "不正な貸借区分です。dc_type=#{hash[:dc_type]}"
      end
    end
    
    ret.values
  end

  def list_journals( ym )
    raise ArgumentError.new("勘定科目の指定がありません。") unless account_id.to_i > 0
    
    ret = []
    details = JournalDetail.includes(:journal_header).references(:journal_header).select(:journal_header_id).where(conditions_for_journals(ym))
    ids = details.map(&:journal_header_id).uniq
    JournalHeader.where(:id => ids).order('ym, day, created_at').includes(:journal_details).each do |jh|
      ret << Ledger.new(jh, self)
    end

    ret
  end

end
