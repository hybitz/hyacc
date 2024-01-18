module Reports
  class TradeAccountReceivableLogic
    include HyaccConst

    def get_trade_account_receivable_model(finder)
      res = []
      ymd = finder.end_year_month_day_of_fiscal_year.to_s
      a = Account.find_by_code(ACCOUNT_CODE_RECEIVABLE)
      
      # 借方
      debits = JournalDetail.where(account_id: a.id, dc_type: DC_TYPE_DEBIT).joins(:journal).where(Journal.arel_table[:ym].lteq ymd[0, 6]).group(:sub_account_id).sum(:amount)
      # 貸方
      credits = JournalDetail.where(account_id: a.id, dc_type: DC_TYPE_CREDIT).joins(:journal).where(Journal.arel_table[:ym].lteq ymd[0, 6]).group(:sub_account_id).sum(:amount)

      debits.each do |key, value|
        sum = 0
        sum = value - credits[key] unless credits[key].nil?
        if sum > 0
          c = Customer.find(key)
          t = Reports::TradeAccountReceivableModel.new
          t.customer_id = key
          t.customer_name = c.formal_name_on(ymd.to_date)
          t.account_receivable = sum
          t.address = c.address
          t.remarks = c.enterprise_number
          res.push(t)
        end
      end
      res
    end
  end

  class TradeAccountReceivableModel
    attr_accessor :customer_id
    attr_accessor :customer_name
    attr_accessor :account_receivable
    attr_accessor :address
    attr_accessor :remarks
  end
end
