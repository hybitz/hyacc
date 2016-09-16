class InvestmentsController < Base::HyaccController
  view_attribute :title => '有価証券'
  view_attribute :finder, :class => InvestmentFinder
  view_attribute :customers, :only => [:new,:create,:edit,:relate], :conditions => {:is_investment => true, :deleted => false}
  view_attribute :bank_accounts, :conditions => {financial_account_type: [FINANCIAL_ACCOUNT_TYPE_GENERAL,
                                                                          FINANCIAL_ACCOUNT_TYPE_SPECIFIC,
                                                                          FINANCIAL_ACCOUNT_TYPE_SPECIFIC_WITHHOLD]}
  
  def index
    check_if_related
    return unless params[:commit]
    finder.bank_account_id = params[:finder][:bank_account_id]
    @investments = finder.list
  end

  def new
    @investment = Investment.new
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
        @investment.journal_detail_id = nil
        save_investment!
      end
      
      flash[:notice] = '有価証券情報を更新しました。'
      render 'common/reload'

    rescue Exception => e
      handle(e)
      render :edit
    end
  end
  
  def relate
    @investment = finder.set_investment_from_journal(params[:journal_header_id])
    render :new
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

  def not_related
    @journal_details = finder.journal_details_not_related
  end
  
  private

  def finder
    unless @finder
      @finder = InvestmentFinder.new(params[:finder])
      @finder.company_id = current_company.id
      @finder.start_month_of_fiscal_year = current_user.company.start_month_of_fiscal_year
      @finder.fiscal_year ||= current_company.fiscal_year
    end
    
    @finder
  end
  
  def investment_params
    params.require(:investment).permit(:name, :yyyymmdd, :sub_account_id, :customer_id, :buying_or_selling, :for_what,
                                       :shares, :trading_value, :bank_account_id, :charges, :journal_detail_id)
  end
  
  def check_if_related
    @has_not_related = finder.is_not_related_to_journal_detail
  end
  
  def save_investment!
    @investment.transaction do
      if @investment.journal_detail_id.nil?
        param = Auto::Journal::InvestmentParam.new(@investment, current_user)
        factory = Auto::Journal::InvestmentFactory.get_instance(param)
        factory.make_journals.each do |jh|
           # 自動仕訳を作成
          Auto::AutoJournalUtil.do_auto_transfers(jh)
          JournalUtil.validate_journal(jh)
          jh.save!
        end
      else
        # 関連付のみの場合は自動仕訳をしない
        @investment.save!
      end
    end
  end
  
  def destroy_investment!
    @investment.transaction do
      if @investment.journal_detail.nil?
        @investment.destroy
      else
         # 有価証券の登録で追加した自動仕訳伝票の場合のみ関連伝票を削除
        jh = @investment.journal_detail.journal_header
        SLIP_TYPE_INVESTMENT == jh.slip_type ? jh.destroy : @investment.destroy
      end
    end
  end
  
end
