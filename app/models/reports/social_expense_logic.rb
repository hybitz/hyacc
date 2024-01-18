module Reports
  class SocialExpenseLogic < BaseLogic

    def build_model
      model = SocialExpenseModel.new
      model.fiscal_year = @finder.fiscal_year
      model.company = Company.find(@finder.company_id)
      model.capital_stock = get_capital_stock_amount
      model.add_detail(get_social_expense_detail_model)
      model.extend_details_up_to( 11 )
      model
    end

    private

    def get_social_expense_detail_model
      ret = SocialExpenseDetailModel.new
      ret.account = Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)

      Journal.where(conditions).includes(:journal_details).each do |jh|
        jh.journal_details.each do |jd|
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
              ret.differential += social_expense_amount if jd.sub_account.code == SUB_ACCOUNT_CODE_DRINKING
            else
              ret.amount -= amount
              ret.deduction_amount -= deduction_amount
              ret.social_expense_amount -= social_expense_amount
              ret.differential -= social_expense_amount if jd.sub_account.code == SUB_ACCOUNT_CODE_DRINKING
            end
          end
        end
      end
      
      ret
    end

    def conditions
      sql = SqlBuilder.new
      sql.append('deleted = ?', false)
      sql.append('and ym >= ? and ym <= ?', start_ym, end_ym)
      sql.append('and finder_key rlike ?', JournalUtil.finder_key_rlike(ACCOUNT_CODE_SOCIAL_EXPENSE, 0, @finder.branch_id))
      sql.to_a
    end

  end

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

    def get_total_differential_amount
      ret = 0
      @details.each {|detail|
        ret += detail.differential.to_i
      }
      ret
    end
    
    def is_zero_deduction
      capital_stock > 100_000_000
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

  class SocialExpenseDetailModel
    attr_accessor :account
    attr_accessor :amount
    attr_accessor :deduction_amount
    attr_accessor :social_expense_amount
    attr_accessor :differential
    
    def initialize
      @amount = 0
      @deduction_amount = 0
      @social_expense_amount = 0
      @differential = 0
    end
  end  
end
