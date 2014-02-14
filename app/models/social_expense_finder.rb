# -*- encoding : utf-8 -*-
#
# $Id: social_expense_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class SocialExpenseFinder < Base::Finder
  include JournalUtil

  def list
    return nil unless commit
    
    JournalHeader.find(:all, :conditions=>make_conditions,
      :order=>"ym desc, day desc, created_on desc").reverse
  end

protected
  # 検索条件を作成する
  def make_conditions
    conditions = []
    
    # 年月
    conditions[0] = "ym >= ? "
    conditions << get_start_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )
    conditions[0] << "and ym <= ? "
    conditions << get_end_year_month_of_fiscal_year( fiscal_year, start_month_of_fiscal_year )

    # finder_key
    conditions[0] << "and finder_key rlike ? "
    conditions << build_rlike_condition( ACCOUNT_CODE_SOCIAL_EXPENSE, 0, branch_id )

    conditions
  end

end
