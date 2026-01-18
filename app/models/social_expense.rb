class SocialExpense
  include ActiveModel::Model
  include HyaccConst

  attr_accessor :id, :code, :name

  def social_expense_number_of_people_required?
    code.to_i == SOCIAL_EXPENSE_TYPE_FOOD_AND_DRINK
  end
end

