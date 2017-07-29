class LedgersController < Base::HyaccController
  view_attribute :title => '元帳'
  view_attribute :accounts, :only => :index
  view_attribute :branches, :only => :index

  helper_method :finder

  def index
    # 月別累計を取得
    @ledgers = finder.list

    # 年月の指定がある場合（損益計算書・貸借対照表からの遷移）、指定月の伝票を取得
    ym = params[:ym].to_i
    if ym > 0
      target_index = HyaccDateUtil.get_ym_index(finder.company.start_month_of_fiscal_year, ym)
      @ledgers.delete_at(target_index)
      @ledgers.insert(target_index, *finder.list_journals(ym))
    end

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
      @finder = LedgerFinder.new(finder_params)
      @finder.company_id = current_company.id
      @finder.fiscal_year ||= current_company.current_fiscal_year.fiscal_year
    end
    @finder
  end

  def finder_params
    return {} unless params[:finder].present?

    permitted = [:fiscal_year, :branch_id, :account_id, :sub_account_id]
    params.require(:finder).permit(permitted)
  end

  def setup_view_attributes
    if finder.account_id.to_i > 0
      @account = Account.get(finder.account_id)
      @sub_accounts = load_sub_accounts(finder.account_id)
    end
    @sub_accounts ||= []
  end
end
