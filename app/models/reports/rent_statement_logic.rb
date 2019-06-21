module Reports
  class RentStatementLogic < BaseLogic

    def get_rent_statement
      rents = {}
      start_from = Date.strptime(@start_ym.to_s + '01', '%Y%m%d')
      end_to = Date.strptime(@end_ym.to_s + HyaccDateUtil.get_days_of_month(@end_ym/100, @end_ym%100).to_s, '%Y%m%d')

      Rent.order('status desc, end_to, start_from').each do |rent|
        rent.total_amount = 0
        rent.start_from = start_from if rent.start_from < start_from
        rent.end_to = end_to if rent.end_to.nil? || rent.end_to > end_to
        rents[rent.id] = rent
      end

      # 端境期対応（通常は補助科目必須とする）
      rents['etc'] = Rent.new(total_amount: 0, address: '不明', remarks: '補助科目が指定されていない伝票', customer: Customer.new)
      Journal.where(conditions(@finder.branch_id)).includes(:journal_details).each do |jh|
        jh.journal_details.each do |jd|
          if jd.account.code == ACCOUNT_CODE_RENT
            sub_account_id = jd.sub_account_id || 'etc'
            if jd.dc_type == jd.account.dc_type
              rents[sub_account_id].total_amount += jd.amount
            else
              rents[sub_account_id].total_amount -= jd.amount
            end
          end
        end
      end

      rents.select{|id, rent| rent.total_amount > 0 }
    end

    private

    def conditions(branch_id)
      sql = SqlBuilder.new
      sql.append('deleted = ?', false)
      sql.append('and ym >= ? and ym <= ?', @start_ym, @end_ym)
      sql.append('and finder_key rlike ?', JournalUtil.build_rlike_condition(ACCOUNT_CODE_RENT, 0, branch_id))
      sql.to_a
    end

  end
end
