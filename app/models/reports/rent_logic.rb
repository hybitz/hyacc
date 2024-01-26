module Reports
  class RentLogic < BaseLogic

    def build_model
      ret = RentModel.new
      start_from = Date.strptime(start_ym.to_s + '01', '%Y%m%d')
      end_to = Date.strptime(end_ym.to_s + HyaccDateUtil.get_days_of_month(end_ym/100, end_ym%100).to_s, '%Y%m%d')

      details = {}
      Rent.order('status desc, end_to, start_from').each do |rent|
        detail = RentDetailModel.new
        detail.rent = rent

          if rent.start_from < start_from
          detail.start_from = start_from
        else
          detail.start_from = rent.start_from
        end

        if rent.end_to.nil? || rent.end_to > end_to
          detail.end_to = end_to
        else
          detail.end_to = rent.end_to
        end

        details[rent.id] = detail
      end

      Journal.where(conditions).includes(:journal_details).each do |jh|
        jh.journal_details.each do |jd|
          next unless jd.account.code == ACCOUNT_CODE_RENT

          if jd.dc_type == jd.account.dc_type
            details[jd.sub_account_id].total_amount += jd.amount
          else
            details[jd.sub_account_id].total_amount -= jd.amount
          end
        end
      end

      details.each do |id, detail|
        next unless detail.total_amount > 0
        ret.add_detail(detail)
      end

      ret
    end

    private

    def conditions
      sql = SqlBuilder.new
      sql.append('deleted = ?', false)
      sql.append('and ym >= ? and ym <= ?', start_ym, end_ym)
      sql.append('and finder_key rlike ?', JournalUtil.build_rlike_condition(ACCOUNT_CODE_RENT, 0, branch_id))
      sql.to_a
    end

  end

  class RentModel
    attr_accessor :details
  
    def initialize
      @details = []
    end

    def add_detail(detail)
      self.details << detail
    end
  end
  
  class RentDetailModel
    attr_accessor :rent
    attr_accessor :total_amount
    attr_accessor :start_from
    attr_accessor :end_to

    def initialize
      @total_amount = 0
    end

    def customer_name
      rent.customer.formal_name_on(end_to)
    end

    def remarks
      rent.customer.enterprise_number
    end

  end
end
