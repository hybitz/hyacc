# -*- encoding : utf-8 -*-
#
# $Id: housework_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class HouseworkFinder < Base::Finder

  def list
    Housework.find(:first, :conditions=>make_conditions)
  end

private
  def make_conditions
    # 年月は必須
    raise ArgumentError.new("会計年度の指定がありません。") unless fiscal_year.to_i > 0

    ret = []
    ret[0] = "fiscal_year = ?"
    ret << fiscal_year
    ret
  end
  
end
