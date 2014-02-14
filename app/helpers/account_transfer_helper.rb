# -*- encoding : utf-8 -*-
#
# $Id: account_transfer_helper.rb 2469 2011-03-23 14:57:42Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module AccountTransferHelper
  def can_transfer_account(jd)
    # 固定資産の勘定科目は資産が関連しているので変更不可
    return false if jd.asset
    can_edit(jd.journal_header)
  end
  
  # 行を強調表示するかどうか
  def should_emphasize(jd)
    return false unless @finder.account_id > 0
    @finder.account_id == jd.account_id
  end
end
