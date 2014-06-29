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
