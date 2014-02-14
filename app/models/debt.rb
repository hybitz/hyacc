# -*- encoding : utf-8 -*-
#
# $Id: debt.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class Debt
  # 仮負債フィールド
  attr_accessor :id
  attr_accessor :ym
  attr_accessor :day
  attr_accessor :remarks
  attr_accessor :transfer_from_id
  attr_accessor :amount
  attr_accessor :branch_id
  attr_accessor :branch_name
  attr_accessor :opposite_branch_id
  attr_accessor :opposite_branch_name
  attr_accessor :closed_id
end
