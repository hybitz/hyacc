module FinancialStatementHelper
  include HyaccConstants

  def colspan( node_level )
    @max_node_level - node_level + 1
  end
  
  # 貸借対照表で表示対象の科目かどうか
  def is_visible_on_bs( account, branch_id )
    return false unless is_visible_on_report( account, branch_id )
    
    # 以下、部門別で表示対象か確認
    
    # 検索条件に部門指定がない場合は全社での出力なので内部取引は表示しない
    if branch_id.to_i == 0
      return false if account.trade_type == TRADE_TYPE_INTERNAL
    else
      branch = Branch.find( branch_id )
  
      # 本店の場合は本店勘定を表示しない
      if account.code == ACCOUNT_CODE_HEAD_OFFICE
        return false if branch.head_office?
      end
      
      # 支店の場合は支店勘定を表示しない
      if account.code == ACCOUNT_CODE_BRANCH_OFFICE
        return false unless branch.head_office?
      end
    end
    
    true
  end
  
  # 損益計算書で表示対象の科目かどうか
  def is_visible_on_pl( account, branch_id )
    return false unless is_visible_on_report( account, branch_id )
    
    # 以下、部門別で表示対象か確認
    
    # 検索条件に部門指定がない場合は全社での出力なので内部取引は表示しない
    if branch_id.to_i == 0
      return false if account.trade_type == TRADE_TYPE_INTERNAL
    else
      branch = Branch.find( branch_id )
      
      if branch.head_office?
        # 本店の場合に表示しない
        return false if [ACCOUNT_CODE_SHARED_COST,
                         ACCOUNT_CODE_SHARED_TAXES].include?(account.code)
      end
    end
    
    true
  end

  private

  def is_visible_on_report( account, branch_id )
    # 削除された科目は表示しない
    return false if account.deleted
    
    # 決算書科目以外は表示しない
    return false unless account.is_settlement_report_account
    
    true
  end

end
