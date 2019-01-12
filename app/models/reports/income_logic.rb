module Reports
  class IncomeLogic < BaseLogic

    def build_model
      ret = IncomeModel.new
      ret.company_name = Company.find(finder.company_id).name
      ret.pretax_profit_amount = get_pretax_profit_amount
      ret.corporate_tax_amount = get_corporate_tax_amount
      
      se_logic = SocialExpenseLogic.new(finder)
      ret.nondiductible_social_expense_amount = se_logic.get_social_expense_model.get_not_loss
      
      ret
    end

  end

  class IncomeModel
    attr_accessor :company_name
    attr_accessor :pretax_profit_amount
    attr_accessor :corporate_tax_amount
    attr_accessor :nondiductible_social_expense_amount
    
    def increase_amount
      corporate_tax_amount
    end
    
    def decrease_amount
      0
    end
    
    # 仮計
    def provisional_total_amount
      @pretax_profit_amount + increase_amount - decrease_amount
    end
    
    # 合計
    def total_amount
      provisional_total_amount
    end
    
    # 総計
    def grand_total_amount
      total_amount
    end
    
    # 差引計
    def balance_amount
      grand_total_amount
    end
    
    # 所得金額又は欠損金額
    def income_amount
      grand_total_amount
    end
  end
end
