module Reports
  class SocialExpenseLogic < BaseLogic

    def get_social_expense_model
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
      ret.account = Account.get_by_code( ACCOUNT_CODE_SOCIAL_EXPENSE )

      JournalHeader.where(conditions).includes(:journal_details).each do |jh|
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
              ret.differential += social_expense_amount if jd.sub_account_id.to_s == SUB_ACCOUNT_CODE_DRINKING
            else
              ret.amount -= amount
              ret.deduction_amount -= deduction_amount
              ret.social_expense_amount -= social_expense_amount
              ret.differential -= social_expense_amount if jd.sub_account_id.to_s == SUB_ACCOUNT_CODE_DRINKING
            end
          end
        end
      end
      
      ret
    end

    def conditions
      sql = SqlBuilder.new
      sql.append('deleted = ?', false)
      sql.append('and ym >= ? and ym <= ?', @start_ym, @end_ym)
      sql.append('and finder_key rlike ?', JournalUtil.finder_key_rlike(ACCOUNT_CODE_SOCIAL_EXPENSE, 0, @finder.branch_id))
      sql.to_a
    end

  end
end
