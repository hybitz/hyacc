class ClosingAccountJob < ActiveJob::Base
  include HyaccConstants
  queue_as :default
  
  def perform(fiscal_year)
    financial_statements = []
    branch_ids = [0]
    fiscal_year.company.branches.each do |branch|
      branch_ids << branch.id
    end

    ApplicationRecord.transaction do
      branch_ids.each do |branch_id|
        pl_data = pl_monthly(fiscal_year, branch_id)
        header = FinancialStatementHeader.new(:company_id => fiscal_year.company.id, :branch_id => branch_id,
                                              :report_type => REPORT_TYPE_PL, :report_style => REPORT_STYLE_MONTHLY,
                                              :fiscal_year => fiscal_year.fiscal_year)
        header.max_node_level = calc_max_node_level(pl_data)
        header.save!
        
        pl_data.each do |account_code, sum|
          account = sum[:account]
          summary = sum[:ym]
          summary.each do |sum|
            financial_statements << FinancialStatement.new(:ym => sum[:ym], :account_id => account.id,
                                                           :account_name => account.name, :amount => sum[:amount],
                                                           :financial_statement_header_id => header.id)
          end
        end
        FinancialStatement.import financial_statements
      end
    end
  end
  
  def pl_monthly(fiscal_year, branch_id)
    @fiscal_year = fiscal_year.fiscal_year
    @company = fiscal_year.company
    @start_month_of_fiscal_year = @company.start_month_of_fiscal_year
    @branch_id = branch_id
    # 収益と費用の勘定科目ツリーを取得
    trees = [
      Account.where('account_type = ? and parent_id is null', ACCOUNT_TYPE_PROFIT).first,
      Account.where('account_type = ? and parent_id is null', ACCOUNT_TYPE_EXPENSE).first
    ]

    # 各科目の月別累計を取得
    sum = {}
    trees.each do |account|
      sum.update(list_monthly_sum(account))
    end
    
    sum
  end
  
  def list_monthly_sum(account)
    ret = {}

    # 自身の累計を取得
    sum = {}
    sum[:account] = account
    sum[:ym] = monthly_sum(account)
    ret[account.code] = sum
    # 子ノードの累計を取得
    account.children.each do |child|
      ret.update(list_monthly_sum(child))
    end
    ret
  end
  
  # 月別累計の配列を取得する
  # 戻り値は、データ構造が12ヶ月分
  # - ym: 年月のyyyymm
  #   amount: 対象となる勘定科目の月別累計金額
  def monthly_sum(account)
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
    sql.append('  and branch_id = ?', @branch_id) if @branch_id > 0
    sql.append('group by jh.ym, jd.dc_type')
    JournalDetail.find_by_sql(sql.to_a).each do |row|
      # 年月からデータを格納する配列のインデックスを算出
      index = row.ym % 100 - @start_month_of_fiscal_year
      index += 12 if index < 0

      if row.dc_type == account.dc_type
        ret[index][:amount] += row.amount
      else
        ret[index][:amount] -= row.amount
      end
    end
  
    ret
  end
  
  def calc_max_node_level(sum)
    max_node_level = 1

    sum.each do |account_code, summary|
      account = summary[:account]
      if account.node_level > max_node_level
        max_node_level = account.node_level
      end
    end
    max_node_level
  end
  
  # 会計年度内の年月を12ヶ月分、yyyymmの配列として取得する。
  def get_ym_range
    start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year(@fiscal_year, @start_month_of_fiscal_year )
    HyaccDateUtil.get_year_months( start_year_month, 12 )
  end
end
