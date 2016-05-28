class FinancialReturnStatementsController < Base::HyaccController
  view_attribute :title => '確定申告'
  view_attribute :finder, :class => ReportFinder
  view_attribute :ym_list
  view_attribute :branches
  view_attribute :report_types

  def index
    case finder.report_type
    when REPORT_TYPE_INCOME
      render_income
    when REPORT_TYPE_RENT
      render_rent
    when REPORT_TYPE_SOCIAL_EXPENSE
      render_social_expense
    when REPORT_TYPE_SURPLUS_RESERVE_AND_CAPITAL_STOCK
      render_surplus_reserve_and_capital_stock
    when REPORT_TYPE_TAX_AND_DUES
      render_tax_and_dues
    when REPORT_TYPE_TRADE_ACCOUNT_PAYABLE
      render_trade_account_payable
    when REPORT_TYPE_TRADE_ACCOUNT_RECEIVABLE
      render_trade_account_receivable
    when REPORT_TYPE_DIVIDEND_RECEIVED
      render_dividend_received
    when REPORT_TYPE_INVESTMENT_SECURITIES
      render_investment_securities
    end if finder.commit
  end

  private

  def render_income
    logic = Reports::IncomeLogic.new(finder)
    @model = logic.get_income_model
    render :income
  end

  def render_rent
    logic = Reports::RentStatementLogic.new(finder)
    @rents = logic.get_rent_statement
    render :rent
  end
  
  def render_surplus_reserve_and_capital_stock
    logic = Reports::SurplusReserveAndCapitalStockLogic.new(finder)
    @model = logic.get_surplus_reserve_and_capital_stock
    render :surplus_reserve_and_capital_stock
  end

  def render_tax_and_dues
    logic = Reports::TaxAndDuesLogic.new(finder)
    @model = logic.get_tax_and_dues_model
    render :tax_and_dues
  end

  def render_social_expense
    logic = Reports::SocialExpenseLogic.new(finder)
    @model = logic.get_social_expense_model
    render render_social_expense_layout(finder.start_year_month_of_fiscal_year)
  end
  
  def render_social_expense_layout(yyyymm)
    case yyyymm
    when (201404..Float::INFINITY)
      return :social_expense_2014
    else
      return :social_expense
    end
  end
  
  # 買掛金の内訳書
  def render_trade_account_payable
    logic = Reports::TradeAccountPayableLogic.new
    @report = logic.get_trade_account_payable_model(finder)
    render :trade_account_payable
  end
  
  # 売掛金の内訳書
  def render_trade_account_receivable
    logic = Reports::TradeAccountReceivableLogic.new
    @report = logic.get_trade_account_receivable_model(finder)
    render :trade_account_receivable
  end
  
  # 受取配当
  def render_dividend_received
    logic = Reports::DividendReceivedLogic.new
    @models = logic.get_dividend_received_model(finder)
    render :dividend_received
  end
  
  # 有価証券
  def render_investment_securities
    logic = Reports::InvestmentLogic.new(finder)
    @investments = logic.get_investments_report
    render :investment_securities
  end
end
