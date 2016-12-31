class AssetFinder
  include ActiveModel::Model
  include Pagination

  attr_accessor :fiscal_year
  attr_accessor :branch_id
  attr_accessor :account_id

  def list
    Asset.where(conditions).order('code').includes([:account, :branch])
        .paginate(:page => page, :per_page => per_page)
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
