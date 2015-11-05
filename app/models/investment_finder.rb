class InvestmentFinder < Daddy::Model
  include HyaccDateUtil
  
  def list
    Investment.where(conditions).order('ym, day')
  end
  
  def fiscal_years
    c = Company.find(company_id)
    c.fiscal_years.map{|fy| fy.fiscal_year }.sort
  end
  
  private

  def conditions
    ym_range = get_ym_range
    sql = SqlBuilder.new
    sql.append('ym <= ? and ym >= ?', ym_range.last, ym_range.first)
    sql.to_a
  end
  
  # 会計年度内の年月を12ヶ月分、yyyymmの配列として取得する。
  def get_ym_range
    start_year_month = get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    get_year_months( start_year_month, 12 )
  end
  
end