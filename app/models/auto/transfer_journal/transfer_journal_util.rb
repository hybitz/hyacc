module Auto::TransferJournal::TransferJournalUtil
  include HyaccConstants
  include HyaccErrors

  def self.get_remarks(original_remarks, account_id)
    a = Account.find(account_id)
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
