module Investments
  include HyaccConst

  def investment_params
    {
      yyyymmdd: '2016-03-27',
      bank_account_id: 3,
      customer_id: 1,
      buying_or_selling: SECURITIES_TRANSACTION_TYPE_BUYING.to_s,
      for_what: 1,
      shares: 20,
      trading_value: 100000,
      charges: 1080
    }
  end

end