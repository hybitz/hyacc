module Reports
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
