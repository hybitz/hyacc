class BalanceByBranch
  attr_accessor :branch_id
  attr_accessor :amount_debit
  attr_accessor :amount_credit
  
  def initialize
    @branch_id = 0
    @amount_debit = 0
    @amount_credit = 0
  end
  
end
