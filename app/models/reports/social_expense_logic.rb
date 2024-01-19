module Reports
  class SocialExpenseLogic < BaseLogic

    def build_model
      model = SocialExpenseModel.new
      model.fiscal_year = finder.fiscal_year
      model.company = company
      model.capital_stock = get_capital_stock_amount
      model.add_detail(build_detail_model)

      model.details.size.upto(11).each do
        model.add_detail(SocialExpenseDetailModel.new)
      end

      model
    end

    def max_food_and_drink_amount_per_person(ym)
      if ym >= 202404
        10_000
      else
        5_000
      end
    end

    private

    def build_detail_model
      ret = SocialExpenseDetailModel.new
      ret.account = Account.find_by_code(ACCOUNT_CODE_SOCIAL_EXPENSE)

      Journal.where(conditions).includes(:journal_details).find_each do |jh|
        jh.journal_details.each do |jd|
          if jd.account.code == ACCOUNT_CODE_SOCIAL_EXPENSE
            amount = jd.amount

            if jd.sub_account.code == SUB_ACCOUNT_CODE_FOOD_AND_DRINK
              max_food_and_drink_amount = jd.social_expense_number_of_people.to_i * max_food_and_drink_amount_per_person(jh.ym)

              if amount > max_food_and_drink_amount
                deduction_amount = amount - max_food_and_drink_amount
                social_expense_amount = max_food_and_drink_amount
                food_and_drink_amount = max_food_and_drink_amount
              else
                deduction_amount = 0
                social_expense_amount = amount
                food_and_drink_amount = amount
              end
            else
              deduction_amount = 0
              social_expense_amount = amount
              food_and_drink_amount = 0
            end

            if jd.dc_type == jd.account.dc_type
              ret.amount += amount
              ret.deduction_amount += deduction_amount
              ret.social_expense_amount += social_expense_amount
              ret.food_and_drink_amount += food_and_drink_amount
            else
              ret.amount -= amount
              ret.deduction_amount -= deduction_amount
              ret.social_expense_amount -= social_expense_amount
              ret.food_and_drink_amount -= food_and_drink_amount
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
      sql.append('and finder_key rlike ?', JournalUtil.finder_key_rlike(ACCOUNT_CODE_SOCIAL_EXPENSE, 0, finder.branch_id))
      sql.to_a
    end

  end

  class SocialExpenseModel
    attr_accessor :company
    attr_accessor :fiscal_year
    attr_accessor :capital_stock
    attr_accessor :date_from
    attr_accessor :date_to
    attr_accessor :details
    
    def initialize
      @details = []
    end
    
    def add_detail(detail)
      @details << detail
    end

    def total_amount
      @details.inject(0){|sum, d| sum + d.amount.to_i }
    end
  
    def total_deduction_amount
      @details.inject(0){|sum, d| sum + d.deduction_amount.to_i }
    end
  
    def total_social_expense_amount
      @details.inject(0){|sum, d| sum + d.social_expense_amount.to_i }
    end

    def total_food_and_drink_amount
      @details.inject(0){|sum, d| sum + d.food_and_drink_amount.to_i }
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
      if get_deduction_limit > total_social_expense_amount
        ret = total_social_expense_amount
      else
        ret = get_decuction_limit
      end
      
      ret * 90 / 100
    end
    
    # 損金不算入額
    def get_not_loss
      total_social_expense_amount - get_loss_limit
    end

    def food_and_drink_base_after_2014
      total_food_and_drink_amount.quo(2).floor
    end
  
    def fixed_deduction_after_2014
      total_social_expense_amount < max_deduction_after_2014 ? total_social_expense_amount : max_deduction_after_2014
    end

    def max_deduction_after_2014
      (8_000_000 * get_business_months).quo(12).floor
    end

    def non_deduction_limit_after_2014
      two = food_and_drink_base_after_2014
      three = fixed_deduction_after_2014
      two > three ? two : three
    end
  
    def non_deduction_after_2014
      total_social_expense_amount - non_deduction_limit_after_2014
    end
  
    def non_deduction_limit_for_2013
      one = total_social_expense_amount
      two = 8000000 * get_business_months / 12
      one > two ? two : one
    end
  
    def non_deduction_for_2013
      total_social_expense_amount - non_deduction_limit_for_2013
    end

  end

  class SocialExpenseDetailModel
    attr_accessor :account
    # 支出額
    attr_accessor :amount
    # 交際費等の額から控除される費用の額
    attr_accessor :deduction_amount
    # 差引交際費等の額
    attr_accessor :social_expense_amount
    # うち接待飲食費の額
    attr_accessor :food_and_drink_amount

    def initialize
      @amount = 0
      @deduction_amount = 0
      @social_expense_amount = 0
      @food_and_drink_amount = 0
    end
  end  

end
