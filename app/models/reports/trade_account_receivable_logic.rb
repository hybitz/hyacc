module Reports
  class TradeAccountReceivableLogic < BaseLogic

    def build_model
      ret = TradeAccountReceivableModel.new

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
          d = Reports::TradeAccountReceivableDetailModel.new
          d.customer_id = key
          d.customer_name = c.formal_name_on(ymd.to_date)
          d.amount = sum
          d.address = c.address
          d.remarks = c.enterprise_number
          ret.add_detail(d)
        end
      end

      ret
    end
  end

  class TradeAccountReceivableModel
    attr_accessor :details
  
    def initialize
      @details = []
    end

    def add_detail(detail)
      self.details << detail
    end

    def total_amount
      details.sum(&:amount)
    end
  end

  class TradeAccountReceivableDetailModel
    attr_accessor :customer_id
    attr_accessor :customer_name
    attr_accessor :amount
    attr_accessor :address
    attr_accessor :remarks
  end
end
