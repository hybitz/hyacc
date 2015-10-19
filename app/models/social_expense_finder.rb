class SocialExpenseFinder < Base::Finder
  include JournalUtil

  def list
    return nil unless commit
    JournalHeader.where(conditions).order('ym, day, created_at')
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('ym >= ?', get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year ))
    sql.append('and ym <= ?', get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year ))
    sql.append('and finder_key rlike ?', build_rlike_condition( ACCOUNT_CODE_SOCIAL_EXPENSE, 0, branch_id ))
    sql.to_a
  end

end
