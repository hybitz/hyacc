module Reports
  class SocialExpenseModel
  
    attr_accessor :date_from
    attr_accessor :date_to
    attr_accessor :details
    attr_accessor :fiscal_year
    attr_accessor :capital_stock
    attr_accessor :company
    
    def initialize
      @details = []
    end
    
    def add_detail( social_expense_detail_model )
      @details << social_expense_detail_model
    end
    
    def extend_details_up_to( number )
      count = number - @details.length
      if count < 0
        return
      end
      
      count.times { |n|
        @details << SocialExpenseDetailModel.new
      }
    end
    
    def get_total_amount
      ret = 0
      @details.each {|detail|
        ret += detail.amount.to_i
      }
      ret
    end
  
    def get_total_deduction_amount
      ret = 0
      @details.each {|detail|
        ret += detail.deduction_amount.to_i
      }
      ret
    end
  
    def get_total_social_expense_amount
      ret = 0
      @details.each {|detail|
        ret += detail.social_expense_amount.to_i
      }
      ret
    end
    
    def is_zero_deduction
      capital_stock > 100000000
    end
    
    # 年間の営業月数を取得する
    # 通常は12ヶ月だが、初年度と最終年度は計算が必要
    def get_business_months
      if fiscal_year == company.founded_fiscal_year.fiscal_year
        founded_month = company.founded_date.month
  
        if founded_month <= company.start_month_of_fiscal_year
          company.start_month_of_fiscal_year - founded_month
        else
          company.start_month_of_fiscal_year - founded_month + 12
        end
      else
        12
      end
    end
    
    # 定額控除限度額
    def get_deduction_limit
      if is_zero_deduction
        0
      else
        4000000 * get_business_months / 12
      end
    end
    
    # 損金算入限度額
    def get_loss_limit
      if get_deduction_limit > get_total_social_expense_amount
        ret = get_total_social_expense_amount
      else
        ret = get_decuction_limit
      end
      
      ret * 90 / 100
    end
    
    # 損金不算入額
    def get_not_loss
      get_total_social_expense_amount - get_loss_limit
    end
    
  end
end
