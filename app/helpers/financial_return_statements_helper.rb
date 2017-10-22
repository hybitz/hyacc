module FinancialReturnStatementsHelper
  
  # 合計行を表示するかどうか
  def should_display_sum(report, index)
    if index != 0 and report.details[index-1].account.code == report.details[index].account.code
      report.details[index+1].nil? or report.details[index+1].account.code != report.details[index].account.code
    else
      false
    end
  end
  
  # 空白行を表示するかどうか
  def should_display_empty_row(report, index)
    return true if index == report.details.size - 1
    return report.details[index].account.id != report.details[index+1].account.id
  end

  def food_and_drink_base_for_2014(food_and_drink)
    food_and_drink.quo(2).floor
  end
  
  def fixed_deduction_for_2014(total_social_expense_amount, business_months)
    fixed_deduction = 8000000 * business_months / 12
    total_social_expense_amount < fixed_deduction ?
              total_social_expense_amount : fixed_deduction
  end
  
  def non_deduction_limit_for_2014(food_and_drink, total_social_expense_amount, business_months)
    two = food_and_drink_base_for_2014(food_and_drink)
    three = fixed_deduction_for_2014(total_social_expense_amount, business_months)
    two > three ? two : three
  end
  
  def non_deduction_for_2014(food_and_drink, total_social_expense_amount, business_months)
    total_social_expense_amount - non_deduction_limit_for_2014(food_and_drink, total_social_expense_amount, business_months)
  end
end
