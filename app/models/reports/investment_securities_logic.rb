module Reports
  class InvestmentSecuritiesLogic < BaseLogic

    def build_model
      ret = InvestSecuritiesModel.new

      get_total_shares_and_trading_values.each do |last_investment|
        get_investments(last_investment).each do |detail|
          ret.add_detail(detail)
        end
      end

      ret
    end

    private

    def get_investments(last)
      details = []

      deals = Investment.where(customer_id: last['customer_id'], bank_account_id: last['bank_account_id'], ym: @finder.get_ym_range).order(:ym)
      if deals.size == 0 and last['shares'] > 0
        c = Customer.find(last['customer_id'])
        ba = BankAccount.find(last['bank_account_id'])
        details << {
          formal_name: c.formal_name,
          last_shares: last['shares'],
          last_trading_value: last['trading_value'],
          shares: 0,
          trading_value: 0,
          gains: 0,
          bank_name: ba.bank_name,
          address: ba.bank_office&.address
         }
      else
        deals.each_with_index do |inv, i|
          details << {:formal_name => i == 0 ? inv.customer.formal_name : '',
                      :last_shares => i == 0 ? last['shares'] : '',
                      :last_trading_value => i == 0 ? last['trading_value'] : '',
                      :deal_date => inv.deal_date,
                      :reason => inv.buying? ? '購入' : '売却',
                      :shares => inv.shares,
                      :trading_value => inv.trading_value,
                      :gains => inv.gains,
                      :bank_name => i == 0 ? inv.bank_account.bank_name : '',
                      :address => i == 0 ? inv.bank_account.bank_office&.address : '',
                      :etc => ''}
        end
      end

      details
    end
    
    # 期末時点の株数と購入額合計
    def get_total_shares_and_trading_values
      sql = SqlBuilder.new
      sql.append('select customer_id, bank_account_id,')
      sql.append("  sum(case when buying_or_selling = #{SECURITIES_TRANSACTION_TYPE_BUYING} then shares else -shares end) as shares,")
      sql.append("  sum(case when buying_or_selling = #{SECURITIES_TRANSACTION_TYPE_BUYING} then trading_value else -trading_value end) as trading_value")
      sql.append('from investments')
      sql.append('where ym <= ?', end_ym)
      sql.append('group by customer_id, bank_account_id')

      Investment.connection.select_all(Investment.__send__(:sanitize_sql_array, sql.to_a))
    end
  end

  class InvestSecuritiesModel
    attr_accessor :details

    def initialize
      @details = []
    end

    def add_detail(detail)
      self.details << detail
    end
  end

end
