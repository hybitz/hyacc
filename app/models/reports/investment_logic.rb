module Reports
  class InvestmentLogic < BaseLogic

    def get_investments_report
      reports = []
      get_total_shares_and_trading_values.each do |last_investment|
        reports.concat(get_investments(last_investment))
      end
      return reports
    end

    private

    def get_investments(last)
      reports = []
      Investment.where(customer_id: last['customer_id'],
                       bank_account_id: last['bank_account_id'],
                       ym: @finder.get_ym_range).order(:ym).each_with_index do |inv, index|
        reports << {:formal_name => index == 0 ? inv.customer.formal_name : '',
                    :last_shares => index == 0 ? last['shares'] : '',
                    :last_trading_value => index == 0 ? last['trading_value'] : '',
                    :ymd => inv.ym.to_s + "%02d"%inv.day,
                    :reason => inv.buying? ? '購入' : '売却',
                    :shares => inv.buying? ? inv.shares : inv.shares * -1,
                    :trading_value => inv.buying? ? inv.trading_value : inv.trading_value * -1,
                    :bank_name => index == 0 ? inv.bank_account.bank_name : '',
                    :address => index == 0 ? inv.bank_account.bank_office && inv.bank_account.bank_office.address : '',
                    :etc => ''}
      end
      reports
    end
    
    # 期末時点の株数と購入額合計
    def get_total_shares_and_trading_values
      sql = SqlBuilder.new
      sql.append('select customer_id, bank_account_id, sum(shares) as shares, sum(trading_value) as trading_value')
      sql.append('from investments')
      sql.append('where ym <= ?', @end_ym)
      sql.append('group by customer_id, bank_account_id')

      Investment.connection.select_all(Investment.__send__(:sanitize_sql_array, sql.to_a))
    end
  end
end
