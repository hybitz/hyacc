class Bs::InvestmentsController < Base::HyaccController
  include BankAccountsAware

  view_attribute :customers, only: [:new,:create,:edit,:update], conditions: {is_investment: true, deleted: false}
  helper_method :finder

  def index
    @investments = finder.list if params[:commit]
  end

  def new
    @investment = Investment.new(buying_or_selling: 1)
  end

  def create
    @investment = Investment.new(investment_params)
    begin
      save_investment!
      flash[:notice] = '有価証券情報を追加しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render :action => 'new'
    end
  end

  def edit
    @investment = Investment.find(params[:id])
  end

  def update
    @investment = Investment.find(params[:id])

    begin
      @investment.transaction do
        destroy_investment!
        @investment = Investment.new(investment_params)
        save_investment!
      end

      flash[:notice] = '有価証券情報を更新しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    @investment = Investment.find(params[:id])
    begin
      destroy_investment!
      flash[:notice] = '有価証券情報を削除しました。'
      redirect_to :action => :index
    rescue => e
      handle(e)
      redirect_to :action => :index
    end
  end

  private

  def finder
    unless @finder
      @finder = InvestmentFinder.new(finder_params)
      @finder.company_id = current_company.id
      @finder.fiscal_year ||= current_company.fiscal_year
      @finder.order = 'ym desc, day desc'
    end

    @finder
  end

  def finder_params
    params.fetch(:finder, {}).permit(:fiscal_year, :bank_account_id)
  end

  def investment_params
    params.require(:investment).permit(:name, :yyyymmdd, :sub_account_id, :customer_id, :buying_or_selling, :for_what,
                                       :shares, :trading_value, :bank_account_id, :charges, :gains)
  end

  def save_investment!
    @investment.transaction do
      if @investment.trading_value != 0
        @investment.save!
        # 自動仕訳を作成
        param = Auto::Journal::InvestmentParam.new(@investment, current_user)
        factory = Auto::Journal::InvestmentFactory.get_instance(param)
        factory.make_journals.each do |jh|
          jh.investment_id = @investment.id
          Auto::AutoJournalUtil.do_auto_transfers(jh)
          JournalUtil.validate_journal(jh)
          jh.save!
        end
      else
        # 取引金額が0円（単元株数変更対応）の場合は自動仕訳しない
        @investment.save!
      end
    end
  end

  def destroy_investment!
    @investment.transaction do
      jh = @investment.journal
      # 伝票区分が有価証券以外の伝票に紐づいている場合は伝票を残し、関連のみ外す。
      # マイグレーション（journal_detail → journal の investment_id 移行）により、
      # 一般振替など伝票区分が有価証券でない既存伝票が investment_id を持っている場合がある。
      if jh.present? && SLIP_TYPE_INVESTMENT != jh.slip_type
        jh.update_column(:investment_id, nil)
        @investment.reload
      end
      @investment.destroy
    end
  end

end
