class InvestmentsController < Base::HyaccController
  view_attribute :title => '有価証券'
  view_attribute :customers, :only => [:new,:create], :conditions => {:is_investment => true, :deleted => false}
  view_attribute :bank_accounts, :conditions => {financial_account_type: [FINANCIAL_ACCOUNT_TYPE_GENERAL,
                                                                          FINANCIAL_ACCOUNT_TYPE_SPECIFIC,
                                                                          FINANCIAL_ACCOUNT_TYPE_SPECIFIC_WITHHOLD]}
  #helper_method :finder
  
  def index
    return unless params[:commit]
    @investments = finder.list
  end

  def new
    @investment = Investment.new
  end
  
  def create
    @investment = Investment.new(investment_params)
    begin
      @investment.save!
      flash[:notice] = '有価証券情報を追加しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render :action => 'new'
    end
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
    params.require(:investment).permit(:name, :yyyymmdd, :sub_account_id, :customer_id, :buying_or_selling,
                                       :shares, :trading_value, :bank_account_id)
  end
end
