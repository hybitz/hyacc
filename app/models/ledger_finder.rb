class LedgerFinder
  include ActiveModel::Model
  include HyaccConst
  include CompanyAware
  include FiscalYearAware

  attr_accessor :account_id
  attr_accessor :branch_id
  attr_accessor :sub_account_id

  def branches
    Branch.get_branches(company_id)
  end
  
  def account
    if account_id.to_i > 0
      @account ||= Account.find(account_id)
    end
    
    @account
  end
  
  def list
    # 科目の指定なしでは検索しない
    return [] unless account_id.to_i > 0

    ym_from = HyaccDateUtil.get_start_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year)
    ym_to = (ym_from / 100 + 1) * 100 + (ym_from % 100)

    ret = {}
    12.times do |i|
      ym = HyaccDateUtil.add_months(ym_from, i)

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

  def list_journals(ym)
    raise ArgumentError.new("勘定科目の指定がありません。") unless account_id.to_i > 0
    
    ret = []
    details = JournalDetail.includes(:journal).references(:journal).select(:journal_id).where(conditions_for_journals(ym))
    ids = details.map(&:journal_id).uniq
    Journal.where(id: ids).order('ym, day, created_at').includes(:journal_details).each do |jh|
      ret << Ledger.new(jh, self)
    end

    ret
  end

  def list_fiscal_years
    fiscal_years
  end
  
  def conditions_for_journals(ym = 0)
    sql = SqlBuilder.new
    sql.append('account_id = ?', account_id)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and journal_details.sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0
    sql.append('and journals.ym = ?', ym) if ym > 0
    sql.to_a
  end

  def get_last_year_balance
    if @last_year_balance.nil?
      unless account and account.bs?
        @last_year_balance = false
      else
        debit = VMonthlyLedger.sum(:amount, conditions_for_last_year_balance(DC_TYPE_DEBIT)).to_i
        credit = VMonthlyLedger.sum(:amount, conditions_for_last_year_balance(DC_TYPE_CREDIT)).to_i
  
        if account.credit?
          @last_year_balance = credit - debit
        else
          @last_year_balance = debit - credit
        end
      end
    end

    @last_year_balance
  end

  private

  # 月別累計検索条件
  def conditions_for_monthly_summary(ym_from, ym_to)
    raise ArgumentError.new("年月の指定がありません。") unless ym_from and ym_to
    raise ArgumentError.new("勘定科目の指定がありません。") unless account_id.to_i > 0

    sql = SqlBuilder.new
    sql.append('company_id = ?', company_id)
    sql.append('and ym >= ? and ym < ?', ym_from, ym_to)
    sql.append('and account_id = ?', account_id)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0

    sql.to_a
  end
  
  # 月別累計検索条件
  def conditions_for_last_year_balance( dc_type )
    raise ArgumentError.new("勘定科目の指定がありません。") unless account
    raise ArgumentError.new("貸借区分の指定がありません。") unless [DC_TYPE_DEBIT, DC_TYPE_CREDIT].include?(dc_type)

    # 前年度末
    start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year(last_year, company.start_month_of_fiscal_year)

    sql = SqlBuilder.new
    sql.append('ym <= ?', HyaccDateUtil.get_year_months( start_year_month, 12 ).last)
    sql.append('and account_id = ?', account_id)
    sql.append('and dc_type = ?', dc_type)
    sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
    sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0

    sql.to_a
  end
  
  def last_year
    fiscal_year.to_i - 1
  end

end
