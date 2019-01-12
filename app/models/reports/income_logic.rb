module Reports
  class IncomeLogic < BaseLogic
    
    def initialize(finder)
      super(finder)
    end
    
    def get_income_model
      model = IncomeModel.new
      model.company_name = Company.find(@finder.company_id).name
      model.pretax_profit_amount = get_pretax_profit_amount
      
      se_logic = SocialExpenseLogic.new(@finder)
      model.nondiductible_social_expense_amount = se_logic.get_social_expense_model.get_not_loss
      
      model
    end
  end
end
