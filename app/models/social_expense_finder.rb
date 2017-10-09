class SocialExpenseFinder
  include ActiveModel::Model
  include HyaccConstants
  include CompanyAware
  include BranchAware

  attr_accessor :fiscal_year

  def list
    Journal.where(conditions).order('ym, day, created_at')
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('ym >= ?', HyaccDateUtil.get_start_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year))
    sql.append('and ym <= ?', HyaccDateUtil.get_end_year_month_of_fiscal_year(fiscal_year, company.start_month_of_fiscal_year))
    sql.append('and finder_key rlike ?', JournalUtil.build_rlike_condition( ACCOUNT_CODE_SOCIAL_EXPENSE, 0, branch_id ))
    sql.to_a
  end

end
