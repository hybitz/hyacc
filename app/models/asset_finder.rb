class AssetFinder < Base::Finder
  
  def list
    Asset.paginate(
      :page=>@page > 0 ? @page : 1,
      :conditions=>make_conditions,
      :order=>"code",
      :per_page=>@slips_per_page,
      :include=>[:account, :branch])
  end

  private

  def make_conditions
    conditions = []
    
    conditions[0] = 'start_fiscal_year <= ? and end_fiscal_year >= ? '
    conditions << fiscal_year
    conditions << fiscal_year
    
    if @branch_id > 0
      conditions[0] << 'and branch_id = ? '
      conditions << @branch_id
    end
    
    if @account_id > 0
      conditions[0] << 'and account_id = ? '
      conditions << @account_id
    end
  
    conditions
  end
end
