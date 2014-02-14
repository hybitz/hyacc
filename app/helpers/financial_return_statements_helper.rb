# -*- encoding : utf-8 -*-
#
# $Id: financial_return_statements_helper.rb 2469 2011-03-23 14:57:42Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module FinancialReturnStatementsHelper
  
  # 合計行を表示するかどうか
  def should_display_sum(report, index)
    if index != 0 and report.details[index-1].account.code == report.details[index].account.code
      report.details[index+1].nil? or report.details[index+1].account.code != report.details[index].account.code
    else
      false
    end
  end
  
  # 空白行を表示するかどうか
  def should_display_empty_row(report, index)
    return true if index == report.details.size - 1
    return report.details[index].account.id != report.details[index+1].account.id
  end
end
