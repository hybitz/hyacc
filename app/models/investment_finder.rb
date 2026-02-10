class InvestmentFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware
  include BankAccountAware

  attr_accessor :fiscal_year
  attr_accessor :order

  def list
    Investment.where(conditions).order(order)
  end
  
  def fiscal_years
    company.fiscal_years.map{|fy| fy.fiscal_year }.sort
  end
  
  def order
    @order || 'ym, day'
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
    start_year_month = HyaccDateUtil.get_start_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year)
    HyaccDateUtil.get_year_months(start_year_month, 12)
  end
  
end