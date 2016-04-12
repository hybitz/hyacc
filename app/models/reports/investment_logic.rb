module Reports
  class InvestmentLogic < BaseLogic
    include JournalUtil
    
    def initialize(finder)
      super(finder)
    end
    
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
      Investment.where(customer_id: last.customer_id,
                       bank_account_id: last.bank_account_id,
                       ym: @finder.get_ym_range).each_with_index do |inv, index|
        reports << {:formal_name => index == 0 ? inv.customer.formal_name : '',
                    :last_shares => index == 0 ? last.shares : '',
                    :last_trading_value => index == 0 ? last.trading_value : '',
                    :ymd => inv.ym.to_s + "%02d"%inv.day  , :reason => inv.shares > 0 ? '購入' : '売却',
                    :shares => inv.shares, :trading_value => inv.trading_value,
                    :bank_name => index == 0 ? inv.bank_account.bank_name : '',
                    :address => index == 0 ? inv.bank_account.bank_office.address ||= "" : '',
                    :etc => ""}
      end
      reports
    end
    
    # 期末時点の株数と購入額合計
    def get_total_shares_and_trading_values()
      arel = Investment.arel_table
      ym_condition = arel[:ym].lteq(@end_ym)
      Investment.where(ym_condition).group(:customer_id,
                                           :bank_account_id).select(:customer_id,
                                                                    :bank_account_id,
                                                                    arel[:shares].sum.as('shares'),
                                                                    arel[:trading_value].sum.as('trading_value'))
    end
  end
end
