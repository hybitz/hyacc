class FinancialStatementController < Base::HyaccController
  view_attribute :title => '決算書'
  view_attribute :finder, :class => ReportFinder
  view_attribute :ym_list
  view_attribute :branches
  view_attribute :report_types
  view_attribute :report_styles

  def index
    if finder.commit
      if finder.report_type == REPORT_TYPE_BS
        if finder.report_style == REPORT_STYLE_MONTHLY
          render_bs_monthly
        elsif finder.report_style == REPORT_STYLE_YEARLY
          render_bs_yearly
        end
      elsif finder.report_type == REPORT_TYPE_PL
        if finder.report_style == REPORT_STYLE_MONTHLY
          render_pl_monthly
        elsif finder.report_style == REPORT_STYLE_YEARLY
          render_pl_yearly
        end
      elsif finder.report_type == REPORT_TYPE_CF
        if finder.report_style == REPORT_STYLE_MONTHLY
          # TODO 月別のCF
        elsif finder.report_style == REPORT_STYLE_YEARLY
          # TODO 年間のCF
        end
      end
    end
  end

  private

  def render_bs_yearly
    # BS関係の勘定科目ツリーを取得
    trees = [
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_ASSET).first,
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_DEBT).first,
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_CAPITAL).first,
    ]
    
    # 各科目のネット累計を取得
    @sum = {}
    trees.each do | tree |
      @sum.update( get_net_sum( tree ) )
    end
    
    # 利益剰余金の計算
    profit_account = Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_PROFIT).first
    expense_account = Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_EXPENSE).first
    # 今期までの利益剰余金累計
    profit = finder.get_net_sum_amount( profit_account )
    expense = finder.get_net_sum_amount( expense_account )
    revenue = profit - expense
    # 前期までの利益剰余金累計は振替済みなので、そこに計算結果を付け足す
    @sum[ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD][:amount] += revenue
    
    # 最大ノードレベルを算出
    calc_max_node_level(@sum)
    
    render :bs_yearly
  end

  def render_bs_monthly
    # BS関係の勘定科目ツリーを取得
    trees = [
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_ASSET).first,
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_DEBT).first,
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_CAPITAL).first,
    ]
    
    # 各科目の月別ネット累計を取得
    @sum = {}
    trees.each do | tree |
      @sum.update( list_monthly_net_sum( tree ) )
    end
    
    # 利益剰余金の計算
    profit_account = Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_PROFIT).first
    expense_account = Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_EXPENSE).first
    # 今期の利益
    profit = finder.list_monthly_sum( profit_account )
    expense = finder.list_monthly_sum( expense_account )
    ym_range = finder.get_ym_range
    ym_range.each_index do |index|
      ym = ym_range[index]
      # 繰越利益剰余に利益利益を設定
      @sum[ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD] ||= {}
      @sum[ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD][:ym][index] = {:ym => ym, :amount => 0}

      (index + 1).times do |i|
        revenue = profit[i][:amount] - expense[i][:amount]
        @sum[ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD][:ym][index][:amount] += revenue
      end

      if HyaccLogger.debug?
        HyaccLogger.debug("年月：[#{ym}] 収益：[#{profit[index][:amount]}] 費用：[#{expense[index][:amount]}] 繰越利益：[#{@sum[ACCOUNT_CODE_EARNED_SURPLUS_CARRIED_FORWARD][:ym][index][:amount]}]")
      end
    end

    # 最大ノードレベルを算出
    calc_max_node_level(@sum)
    
    render :bs_monthly
  end

  def list_monthly_net_sum( account )
    ret = {}

    # 自身の累計を取得
    sum = {}
    sum[:account] = account
    sum[:ym] = finder.list_monthly_net_sum( account )
    ret[account.code] = sum
    
    # 子ノードの累計を取得
    account.children.each do | child |
      ret.update( list_monthly_net_sum( child ) )
    end
    
    ret
  end

  def get_net_sum( account )
    # 決算書科目のみが対象
    return nil unless account.is_settlement_report_account

    ret = {}
    ret[account.code] = {}
    ret[account.code][:account] = account

    # リーフの場合は累計を取得
    if account.is_leaf_on_settlement_report
      ret[account.code][:amount] = finder.get_net_sum_amount( account )
    end

    # 子ノードの累計を取得
    account.children.each do |child|
      net_sum = get_net_sum( child )
      ret.update( net_sum ) if net_sum
    end

    ret
  end
  
  def render_pl_monthly()
    # 収益と費用の勘定科目ツリーを取得
    trees = [
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_PROFIT).first,
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_EXPENSE).first,
    ]
    
    # 各科目の月別累計を取得
    @sum = {}
    trees.each do | tree |
      @sum.update( list_monthly_sum( tree ) )
    end
    
    # 最大ノードレベルを算出
    calc_max_node_level(@sum)
    
    render :pl_monthly
  end

  def render_pl_yearly()
    # 収益と費用の勘定科目ツリーを取得
    trees = [
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_PROFIT).first,
      Account.where("account_type=? and parent_id is null", ACCOUNT_TYPE_EXPENSE).first,
    ]
    
    # 各科目の月別累計を取得
    @sum = {}
    trees.each do | tree |
      @sum.update( list_yearly_sum( tree ) )
    end
    
    # 最大ノードレベルを算出
    calc_max_node_level(@sum)
    
    render :pl_yearly
  end

  def list_monthly_sum( account )
    ret = {}
    
    # 自身の累計を取得
    sum = {}
    sum[:account] = account
    sum[:ym] = finder.list_monthly_sum( account )
    ret[account.code] = sum
    
    # 子ノードの累計を取得
    account.children.each do | child |
      ret.update( list_monthly_sum( child ) )
    end
    
    ret
  end
  
  def list_yearly_sum( account )
    ret = {}
    
    # 自身の累計を取得
    sum = {}
    sum[:account] = account
    sum[:amount] = finder.get_yearly_net_sum(account)
    ret[account.code] = sum
    
    # 子ノードの累計を取得
    account.children.each do | child |
      ret.update( list_yearly_sum( child ) )
    end
    
    ret
  end

  def calc_max_node_level(sum)
    max_node_level = 1

    sum.each do |elem|
      a = elem[1][:account]
      if a.node_level > max_node_level
        max_node_level = a.node_level
      end
    end
    
    @max_node_level = max_node_level
  end
end
