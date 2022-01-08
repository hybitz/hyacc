class MonthlyLedger
    include HyaccConst

    attr_accessor :ym
    attr_accessor :amount_debit
    attr_accessor :amount_credit

  def has_amount
    self.amount_debit.to_i + self.amount_credit.to_i > 0
  end
end
