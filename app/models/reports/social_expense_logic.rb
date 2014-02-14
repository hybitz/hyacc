# -*- encoding : utf-8 -*-
module Reports
  class SocialExpenseLogic < BaseLogic
    include JournalUtil
    
    def initialize(finder)
      super(finder)
    end
    
    def get_social_expense_model
      model = SocialExpenseModel.new
      model.fiscal_year = @finder.fiscal_year
      model.company = Company.find(@finder.company_id)
      model.capital_stock = get_capital_stock_amount
      model.add_detail( get_social_expense_detail_model() )
      model.extend_details_up_to( 11 )
      model
    end

  private
    def get_social_expense_detail_model
      ret = SocialExpenseDetailModel.new
      ret.account = Account.get_by_code( ACCOUNT_CODE_SOCIAL_EXPENSE )
      
      JournalHeader.find(:all, :conditions=>make_conditions(ACCOUNT_CODE_SOCIAL_EXPENSE), :include=>[:journal_details]).each {|jh|
        jh.journal_details.each {|jd|
          if jd.account.code == ACCOUNT_CODE_SOCIAL_EXPENSE
            number_of_people = jd.social_expense_number_of_people.to_i
            amount = jd.amount
            deduction_amount = number_of_people * 5000
          
            if jd.amount >  deduction_amount
              social_expense_amount = jd.amount - deduction_amount
            else
              deduction_amount = amount
              social_expense_amount = 0
            end
            
            if jd.dc_type == jd.account.dc_type
              ret.amount += amount
              ret.deduction_amount += deduction_amount
              ret.social_expense_amount += social_expense_amount
            else
              ret.amount -= amount
              ret.deduction_amount -= deduction_amount
              ret.social_expense_amount -= social_expense_amount
            end
          end
        }
      }
      
      ret
    end

    # 検索条件を作成する
    def make_conditions(account_code)
      conditions = []
      
      # 年月
      conditions[0] = "ym >= ? "
      conditions << @start_ym
      conditions[0] << "and ym <= ? "
      conditions << @end_ym
  
      # finder_key
      conditions[0] << "and finder_key rlike ? "
      conditions << build_rlike_condition( account_code, 0, @finder.branch_id )
  
      conditions
    end

  end
end
