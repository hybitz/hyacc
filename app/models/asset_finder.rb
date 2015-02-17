class AssetFinder < Daddy::Model
  
  def list
    Asset.where(conditions).order('code').includes([:account, :branch])
        .paginate(:page => page, :per_page => per_page)
  end

  def fiscal_years
    c = Company.find(company_id)
    c.fiscal_years.map{|fy| fy.fiscal_year }.sort
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('start_fiscal_year <= ? and end_fiscal_year >= ?', fiscal_year, fiscal_year)
    sql.append('and branch_id = ?', branch_id) if branch_id.present?
    sql.append('and account_id = ?', account_id) if account_id.present?
    sql.to_a
  end
end
