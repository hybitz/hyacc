module Reports
  class Appendix04Logic < BaseLogic

    def build_model
      ret = Appendix04Model.new
      ret.company = Company.find(finder.company_id)
      ret.fiscal_year = ret.company.get_fiscal_year(finder.fiscal_year)
      ret.pretax_profit_amount = get_profit_amount
      ret.corporate_tax_amount = get_corporate_tax_amount
      ret.corporate_inhabitant_tax_amount = get_corporate_inhabitant_tax_amount
      ret.business_tax_amount = get_business_tax_amount
      ret.exective_bonus_amount = get_this_term_amount(ACCOUNT_CODE_EXECUTIVE_BONUS)
      
      se_logic = Appendix15Logic.new(finder)
      ret.appendix_15_model = se_logic.build_model

      dr_logic = Appendix08Logic.new(finder)
      ret.appendix_08_model = dr_logic.build_model

      dn_logic = Appendix1402Logic.new(finder)
      ret.appendix_14_02_model = dn_logic.build_model(ret.provisional_amount)
      ret
    end

  end

  class Appendix04Model
    attr_accessor :company
    attr_accessor :fiscal_year
    attr_accessor :pretax_profit_amount
    attr_accessor :corporate_tax_amount
    attr_accessor :corporate_inhabitant_tax_amount
    attr_accessor :business_tax_amount
    attr_accessor :appendix_08_model
    attr_accessor :appendix_15_model
    attr_accessor :appendix_14_02_model
    attr_accessor :exective_bonus_amount

    def company_name
      company.name
    end
    
    def pretax_profit_retained_amount
      0
    end
    
    def pretax_profit_outflow_amount
      0
    end

    # 加算の小計
    def increase_amount
      corporate_tax_amount + corporate_inhabitant_tax_amount + exective_bonus_amount
    end
    
    def increase_retained_amount
      corporate_tax_amount + corporate_inhabitant_tax_amount
    end

    def increase_outflow_amount
      exective_bonus_amount
    end

    # 減算の小計
    def decrease_amount
      fiscal_year.accepted_amount_of_excess_depreciation + 
        appendix_08_model.non_deductible_amount + 
        fiscal_year.approved_loss_amount_of_business_tax
    end
    
    def decrease_retained_amount
      fiscal_year.accepted_amount_of_excess_depreciation + 
        fiscal_year.approved_loss_amount_of_business_tax
    end
    
    def decrease_outflow_amount
      appendix_08_model.non_deductible_amount 
    end

    # 仮計
    def provisional_amount
      pretax_profit_amount + increase_amount - decrease_amount
    end
    
    # 仮計（留保）
    def provisional_retained_amount
      pretax_profit_retained_amount + increase_retained_amount - decrease_retained_amount
    end

    # 仮計（社外流出）
    def provisional_outflow_amount
      pretax_profit_outflow_amount + increase_outflow_amount - decrease_outflow_amount
    end

    # 合計
    def total_amount
      provisional_amount
    end
    
    # 合計（留保）
    def total_retained_amount
      provisional_retained_amount
    end

    # 合計（社外流出）
    def total_outflow_amount
      provisional_outflow_amount
    end

    # 総計
    def grand_total_amount
      total_amount
    end
    
    # 総計（留保）
    def grand_total_retained_amount
      total_retained_amount
    end

    # 総計（社外流出）
    def grand_total_outflow_amount
      total_outflow_amount
    end

    # 差引計
    def balance_amount
      grand_total_amount
    end
    
    # 差引計（留保）
    def balance_retained_amount
      grand_total_retained_amount
    end

    # 差引計（社外流出）
    def balance_outflow_amount
      grand_total_outflow_amount
    end

    # 所得金額又は欠損金額
    def income_amount
      balance_amount
    end
    
    # 所得金額又は欠損金額（留保）
    def income_retained_amount
      balance_retained_amount
    end

    # 所得金額又は欠損金額（社外流出）
    def income_outflow_amount
      balance_outflow_amount
    end

  end
end
