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
    investment_ids = Account.where(Account.arel_table[:path].matches('%' + ACCOUNT_CODE_SECURITIES + '%')).pluck(:id)
    JournalDetail.where(:account_id => investment_ids).pluck(:id).each do |id|
      if not Investment.exists?(:journal_detail_id => id)
        return true
      end
    end
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