class AssetFinder < Base::Finder
  
  def list
    Asset.where(conditions).order('code').includes([:account, :branch])
        .paginate(:page => @page > 0 ? @page : 1, :per_page => @slips_per_page)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('start_fiscal_year <= ? and end_fiscal_year >= ?', fiscal_year, fiscal_year)
    sql.append('and branch_id = ?', @branch_id) if @branch_id > 0
    sql.append('and account_id = ?', @account_id) if @account_id > 0
    sql.to_a
  end
end
