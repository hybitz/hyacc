# -*- encoding : utf-8 -*-
#
# $Id: transfer_journal_util.rb 2740 2011-12-12 15:00:19Z ichy $
# Product: hyacc
# Copyright 2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Auto::TransferJournal::TransferJournalUtil
    include JournalUtil
  
    def get_remarks(original_remarks, account_id)
      a = Account.get(account_id)
      if a.account_type == ACCOUNT_TYPE_DEBT
        return original_remarks + '【負債配賦】'
      elsif a.account_type == ACCOUNT_TYPE_ASSET
        return original_remarks + '【資産配賦】'
      else
        HyaccLogger.error ERR_INVALID_ACCOUNT_TYPE << "account_id=#{account_id}"
        raise HyaccException.new(ERR_INVALID_ACCOUNT_TYPE)
      end
    end
end
