# -*- encoding : utf-8 -*-
#
# $Id: financial_return_statements_controller.rb 2467 2011-03-23 14:56:39Z ichy $
# Product: hyacc
# Copyright 2009-2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class FinancialReturnStatementsController < Base::HyaccController
  include JournalUtil

  available_for :type=>:company_type, :except=>COMPANY_TYPE_PERSONAL
  view_attribute :finder, :class=>ReportFinder
  view_attribute :ym_list
  view_attribute :branches
  view_attribute :report_types

  def list
    return unless finder.commit
      
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
    end
  end

private
  def render_income
    logic = Reports::IncomeLogic.new(finder)
    @model = logic.get_income_model
    render :income
  end

  def render_rent
    logic = Reports::RentStatementLogic.new
    @rents = logic.get_rent_statement(finder)
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
    render :social_expense
  end
  
  # 買掛金の内訳書
  def render_trade_account_payable
    logic = Reports::TradeAccountPayableLogic.new
    @report = logic.get_trade_account_payable_model(finder)    
    render :trade_account_payable
  end

end
