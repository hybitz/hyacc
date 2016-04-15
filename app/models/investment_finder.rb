class InvestmentFinder < Base::Finder
  include HyaccDateUtil
  
  attr_accessor :bank_account_id
  
  def list
    Investment.where(conditions).order('ym, day')
  end
  
  def fiscal_years
    c = Company.find(company_id)
    c.fiscal_years.map{|fy| fy.fiscal_year }.sort
  end
  
  def is_not_related_to_journal_detail
    journal_details_for_investment.each do |jd|
      if not Investment.exists?(:journal_detail_id => jd.id)
        return true
      end
    end
  end
  
  def journal_details_not_related
    journal_details = []
    journal_details_for_investment.each do |jd|
      if not Investment.exists?(:journal_detail_id => jd.id)
        journal_details << jd
      end
    end
    journal_details
  end

  def journal_details_for_investment
    investment_ids = Account.where(Account.arel_table[:path].matches('%' + ACCOUNT_CODE_SECURITIES + '%')).pluck(:id)
    JournalDetail.where(:account_id => investment_ids)
  end
  
  def set_investment_from_journal(journal_header_id)
    investment = Investment.new
    investment_ids = Account.where(Account.arel_table[:path].matches('%' + ACCOUNT_CODE_SECURITIES + '%')).pluck(:id)
    paid_fee_id = Account.get_by_code(ACCOUNT_CODE_PAID_FEE).id
    investment_securities_id = Account.get_by_code(ACCOUNT_CODE_INVESTMENT_SECURITIES).id
    
    jh = JournalHeader.find(journal_header_id)
    investment.yyyymmdd = jh.ym.to_s.insert(4, '-') + '-' + "%02d" % jh.day.to_s
    
    jh.journal_details.each do |jd|
      if investment_ids.include?(jd.account_id)
        investment.buying_or_selling = jd.dc_type == DC_TYPE_DEBIT ? '1' : '0'
        investment.for_what = jd.account_id == investment_securities_id ? SECURITIES_TYPE_FOR_INVESTMENT : ACCOUNT_CODE_TRADING_SECURITIES
        investment.trading_value = jd.amount
        investment.journal_detail_id = jd.id
      end
      if paid_fee_id == jd.account_id
        investment.charges = jd.amount
      end
    end
    
    investment
  end
  
  private
  
  def conditions
    ym_range = get_ym_range
    sql = SqlBuilder.new
    sql.append('bank_account_id = ? and ym >= ? and ym <= ?', self.bank_account_id, ym_range.first, ym_range.last)
    sql.to_a
  end
  
  # 会計年度内の年月を12ヶ月分、yyyymmの配列として取得する。
  def get_ym_range
    start_year_month = get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    get_year_months( start_year_month, 12 )
  end
  
end