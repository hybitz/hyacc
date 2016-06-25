class ReportFinder < Base::Finder
  attr_reader :company_id
  attr_reader :report_type
  attr_reader :report_style

  def initialize(user)
    super(user)
    @company_id = user.company.id
  end
  
  def setup_from_params( params )
    super(params)
    if params
      @report_type = params[:report_type].to_i
      @report_style = params[:report_style].to_i
    end
  end

  # 指定年月までの累計を求める
  def get_net_sum_until(ym, account)
    VMonthlyLedger.get_net_sum_amount(nil, ym, account.id, 0, branch_id, :ym_to_exclusive => true)
  end

  # 月別累計の配列を取得する
  # 戻り値は、データ構造が12ヶ月分
  # - ym: 年月のyyyymm
  #   amount: 対象となる勘定科目の月別累計金額
  def list_monthly_sum(account)
    raise '勘定科目の指定がありません。' unless account

    ym_range = get_ym_range
    
    # データの受け皿の準備
    ret = []
    ym_range.each do | ym |
      ret << {:ym => ym, :amount => 0}
    end
    
    # 1期分の月別累計情報を検索
    sql = SqlBuilder.new
    sql.append('select')
    sql.append('  jh.ym,')
    sql.append('  jd.dc_type,')
    sql.append('  sum(jd.amount) as amount')
    sql.append('from journal_details jd')
    sql.append('inner join journal_headers jh on (jh.id = jd.journal_header_id)')
    sql.append('inner join accounts a on (a.id = jd.account_id)')
    sql.append('where ym >= ? and ym <= ?', ym_range.first, ym_range.last)
    sql.append('  and path like ?', '%' + account.path + '%')
    sql.append('  and branch_id = ?', branch_id) if branch_id > 0
    sql.append('group by jh.ym, jd.dc_type')
    JournalDetail.find_by_sql(sql.to_a).each do |row|
      # 年月からデータを格納する配列のインデックスを算出
      index = row.ym % 100 - start_month_of_fiscal_year
      index += 12 if index < 0

      if row.dc_type == account.dc_type
        ret[index][:amount] += row.amount
      else
        ret[index][:amount] -= row.amount
      end
    end
  
    ret
  end

  # 年度末までの累計金額を求める
  def get_net_sum_amount(account)
    ret = 0

    sql = SqlBuilder.new
    sql.append('select')
    sql.append('  jd.dc_type,')
    sql.append('  sum(jd.amount) as amount')
    sql.append('from journal_details jd')
    sql.append('inner join journal_headers jh on (jh.id = jd.journal_header_id)')
    sql.append('inner join accounts a on (a.id = jd.account_id)')
    sql.append('where jh.ym <= ?', end_year_month_of_fiscal_year)
    sql.append('  and a.path like ?', '%' + account.path + '%')
    sql.append('  and jd.branch_id = ?', branch_id) if branch_id > 0
    sql.append('group by jd.dc_type')
    JournalDetail.find_by_sql(sql.to_a).each do |row|
      if row.dc_type == account.dc_type
        ret += row.amount
      else
        ret -= row.amount
      end
    end

    ret
  end

  def get_yearly_net_sum(account)
    ret = 0

    sql = SqlBuilder.new
    sql.append('select')
    sql.append('  jd.dc_type,')
    sql.append('  sum(jd.amount) as amount')
    sql.append('from journal_details jd')
    sql.append('inner join journal_headers jh on (jh.id = jd.journal_header_id)')
    sql.append('inner join accounts a on (a.id = jd.account_id)')
    sql.append('where jh.ym >= ? and jh.ym <= ?', start_year_month_of_fiscal_year, end_year_month_of_fiscal_year)
    sql.append('  and a.path like ?', '%' + account.path + '%')
    sql.append('  and jd.branch_id = ?', branch_id) if branch_id > 0
    sql.append('group by jd.dc_type')
    JournalDetail.find_by_sql(sql.to_a).each do |row|
      if row.dc_type == account.dc_type
        ret += row.amount
      else
        ret -= row.amount
      end
    end

    ret
  end

  # 対象範囲年月のネット累計金額の配列を取得する
  # 戻り値は、データ構造が12ヶ月分
  # - ym: 年月のyyyymm
  #   amount: 対象となる勘定科目のその月までのネット累計金額
  def list_monthly_net_sum(account)
    raise '勘定科目の指定がありません。' unless account

    ym_range = get_ym_range
    
    # データの受け皿の準備
    ret = []
    ym_range.each do | ym |
      ret << {:ym => ym, :amount => 0}
    end

    # 1月目までの累計を取得
    sql = SqlBuilder.new
    sql.append('select')
    sql.append('  jh.ym,')
    sql.append('  jd.dc_type,')
    sql.append('  sum(jd.amount) as amount')
    sql.append('from journal_details jd')
    sql.append('inner join journal_headers jh on (jh.id = jd.journal_header_id)')
    sql.append('inner join accounts a on (a.id = jd.account_id)')
    sql.append('where ym <= ?', ym_range.first)
    sql.append('  and path like ?', '%' + account.path + '%')
    sql.append('  and branch_id = ?', branch_id) if branch_id > 0
    sql.append('group by jh.ym, jd.dc_type')
    JournalDetail.find_by_sql(sql.to_a).each do |row|
      if row.dc_type == account.dc_type
        ret[0][:amount] += row.amount
      else
        ret[0][:amount] -= row.amount
      end
    end
    
    # 2月目からの月別累計情報を検索
    sql = SqlBuilder.new
    sql.append('select')
    sql.append('  jh.ym,')
    sql.append('  jd.dc_type,')
    sql.append('  sum(jd.amount) as amount')
    sql.append('from journal_details jd')
    sql.append('inner join journal_headers jh on (jh.id = jd.journal_header_id)')
    sql.append('inner join accounts a on (a.id = jd.account_id)')
    sql.append('where ym > ? and ym <= ?', ym_range.first, ym_range.last)
    sql.append('  and path like ?', '%' + account.path + '%')
    sql.append('  and branch_id = ?', branch_id) if branch_id > 0
    sql.append('group by jh.ym, jd.dc_type')
    JournalDetail.find_by_sql(sql.to_a).each do |row|
      # 年月からデータを格納する配列のインデックスを算出
      index = row.ym % 100 - start_month_of_fiscal_year
      index += 12 if index < 0
      
      if row.dc_type == account.dc_type
        ret[index][:amount] += row.amount
      else
        ret[index][:amount] -= row.amount
      end
    end
    
    # 個々の月に前月までの累計を加算する
    ret.each_index do |index|
      next if index == 0
      ret[index][:amount] += ret[index-1][:amount]
    end
  
    ret
  end

  # 会計年度内の年月を12ヶ月分、yyyymmの配列として取得する。
  def get_ym_range
    start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    HyaccDateUtil.get_year_months( start_year_month, 12 )
  end

end
