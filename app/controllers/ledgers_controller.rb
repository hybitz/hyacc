class LedgersController < Base::HyaccController
  view_attribute :title => '元帳'
  view_attribute :ym_list, :only => :index
  view_attribute :accounts, :only => :index
  view_attribute :branches, :only => :index

  helper_method :finder

  def index
    # 月別累計を取得
    @ledgers = finder.list
    
    # 年月の指定がある場合（損益計算書・貸借対照表からの遷移）、指定月の伝票を取得
    ym = params[:ym].to_i
    if ym > 0
      target_index = HyaccDateUtil.get_ym_index( finder.start_month_of_fiscal_year, ym )
      @ledgers.delete_at( target_index )
      @ledgers.insert( target_index, *finder.list_journals( ym ) )
    end
    
    # 前年度末残高を取得
    @last_year_balance = finder.get_last_year_balance
    setup_view_attributes
  end

  def show
    ym = params[:id].to_i
    @ledgers = finder.list_journals(ym)
    render :partial => 'show'
  end

  private

  def finder
    unless @finder
      @finder = LedgerFinder.new(params[:finder])
      @finder.start_month_of_fiscal_year = current_user.company.start_month_of_fiscal_year
      @finder.fiscal_year ||= current_user.company.current_fiscal_year.fiscal_year
    end
    @finder
  end

  def setup_view_attributes
    if finder.account_id.to_i > 0
      @account = Account.get(finder.account_id)
      @sub_accounts = load_sub_accounts(finder.account_id)
    end
    @sub_accounts ||= []
  end
end
