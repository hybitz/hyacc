module FinancialStatementHelper
  include HyaccConst

  def colspan( node_level )
    @max_node_level - node_level + 1
  end
  
  def is_visible_on_report( account, branch_id )
    # 削除された科目は表示しない
    return false if account.deleted?
    
    # 決算書科目以外は表示しない
    return false unless account.is_settlement_report_account?
    
    # 検索条件に部門指定がない場合は全社での出力なので内部取引は表示しない
    if branch_id.to_i == 0
      return false if account.internal_trade?
    end

    true
  end

end
