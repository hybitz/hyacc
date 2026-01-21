module Reports
  class Appendix1402Logic < BaseLogic
    # 本ロジックは以下の制限があります：
    # ・「公益法人等」の場合の入力項目(25~40行)は未対応
    # ・明細の日付と「寄附した日」または「支出した日」が一致する場合のみ対応
    # ・「資本等を有する法人」のみ対応
    # ・寄附金は借方のみ計上されるケースのみ対応
    # ・「その他の寄附金額」（3行目）の欄には「国外関連者に対する寄附金額及び本店等に対する内部寄附金額」(19行目)と「特定公益信託(認定特定公益信託を除く。)に対する支出金」も含めるという前提で計算する
    # ・下段の明細は日付、金額のみ対応
    include HyaccConst
  
    def build_model
      ret = Appendix1402Model.new
      ret.company = company
      ret.fiscal_year = finder.fiscal_year
      ret.capital_stock_end_amount = Appendix0501Logic.new(finder).build_model.capital_stocks.select{|d|[32, 33].include?(d.no)}.inject(0){|sum, d| sum + d.amount_at_end}
      ret.provisional_income_amount = Appendix04Logic.new(finder).build_model.provisional_amount
      
      donations_data = fetch_all_donations_data

      ret.donations_designated_details = build_details(donations_data[:designated])
      ret.donations_public_interest_details = build_details(donations_data[:public_interest])
      ret.donations_non_certified_trust_details = build_details(donations_data[:non_certified_trust])

      ret.donations_designated_amount = calculate_total_amount(donations_data[:designated])
      ret.donations_public_interest_amount = calculate_total_amount(donations_data[:public_interest])
      ret.donations_non_certified_trust_amount = calculate_total_amount(donations_data[:non_certified_trust])
      ret.donations_fully_controlled_amount = calculate_total_amount(donations_data[:fully_controlled])
      ret.donations_foreign_affiliate_amount = calculate_total_amount(donations_data[:foreign_affiliate])
      ret.donations_others_amount = calculate_total_amount(donations_data[:others])

      ret
    end

    def build_details(donations)
      details = []
      [donations.size, 3].max.times do |i|
        jd = donations[i]
        detail = Appendix1402DetailModel.new
        detail.ymd = build_date_from_journal(jd.journal) if jd.present?
        detail.amount = jd.amount if jd.present?
        details << detail
      end
      details
    end

    def build_date_from_journal(journal)
      return nil unless journal.present?
      year = journal.ym / 100
      month = journal.ym % 100
      Date.new(year, month, journal.day)
    end

    private

    DONATION_SUB_ACCOUNT_CODES = {
      designated: SUB_ACCOUNT_CODE_DONATION_DESIGNATED,
      public_interest: SUB_ACCOUNT_CODE_DONATION_PUBLIC_INTEREST,
      non_certified_trust: SUB_ACCOUNT_CODE_DONATION_NON_CERTIFIED_TRUST,
      fully_controlled: SUB_ACCOUNT_CODE_DONATION_FULLY_CONTROLLED,
      foreign_affiliate: SUB_ACCOUNT_CODE_DONATION_FOREIGN_AFFILIATE,
      others: SUB_ACCOUNT_CODE_DONATION_OTHERS
    }.freeze

    def fetch_and_group_donations(ym_start, ym_end)
      cache_key = [ym_start, ym_end, branch_id]
      @donation_journal_details_cache ||= {}

      return @donation_journal_details_cache[cache_key] if @donation_journal_details_cache.key?(cache_key)

      sub_accounts = SubAccount.where(code: DONATION_SUB_ACCOUNT_CODES.values).pluck(:code, :id).to_h
      account_id = Account.find_by(code: ACCOUNT_CODE_DONATION).id

      donation_details = JournalDetail.where(account_id: account_id, sub_account_id: sub_accounts.values)
      donation_details = donation_details.where(branch_id: branch_id) if branch_id > 0
      donation_details = donation_details.joins(:journal).where("journals.ym >= ? and journals.ym <= ?", ym_start, ym_end).includes(:journal).to_a

      grouped = donation_details.group_by(&:sub_account_id)
      result = {}
      sub_accounts.each do |code, sub_account_id|
        sym = DONATION_SUB_ACCOUNT_CODES.key(code)
        result[sym] = grouped[sub_account_id] || []
      end

      @donation_journal_details_cache[cache_key] = result
    end

    def fetch_all_donations_data
      fetch_and_group_donations(start_ym, end_ym)
    end

    def calculate_total_amount(journal_details)
      journal_details.select { |detail| detail.dc_type == DC_TYPE_DEBIT }.inject(0) { |sum, detail| sum + detail.amount.to_i }
    end
  end 
  
  class Appendix1402Model
    attr_accessor :company, :fiscal_year, :capital_stock_end_amount, :provisional_income_amount
    attr_accessor :donations_designated_details, :donations_public_interest_details, :donations_non_certified_trust_details
    attr_accessor :donations_designated_amount, :donations_public_interest_amount, :donations_non_certified_trust_amount
    attr_accessor :donations_fully_controlled_amount, :donations_foreign_affiliate_amount, :donations_others_amount

    def donations_others_amount_incl_foreign_affiliate_and_non_certified_trust
      donations_others_amount + donations_foreign_affiliate_amount + donations_non_certified_trust_amount
    end

    def donations_total_amount
      donations_designated_amount + donations_public_interest_amount + donations_others_amount_incl_foreign_affiliate_and_non_certified_trust
    end

    def donations_total_amount_incl_fully_controlled
      donations_total_amount + donations_fully_controlled_amount
    end

    def provisional_income_amount_incl_donations
      [provisional_income_amount + donations_total_amount_incl_fully_controlled, 0].max
    end

    def provisional_income_amount_incl_donations_2_5_rate
      # 「資本等を有する法人」の場合は寄附金支出前所得金額の2.5%相当額
      (provisional_income_amount_incl_donations * 0.025).floor
    end

    def capital_stock_end_amount_by_business_month
      ((capital_stock_end_amount * get_business_months).quo(12)).floor
    end

    def capital_stock_end_amount_by_business_month_0_25_rate
      (capital_stock_end_amount_by_business_month * 0.0025).floor
    end

    def deductible_limit_amount_for_general_donations
      ((provisional_income_amount_incl_donations_2_5_rate + capital_stock_end_amount_by_business_month_0_25_rate).quo(4)).floor
    end

    def provisional_income_amount_incl_donations_6_25_rate
      (provisional_income_amount_incl_donations * 0.0625).floor
    end

    def capital_stock_end_amount_by_business_month_0_375_rate
      (capital_stock_end_amount_by_business_month * 0.00375).floor
    end

    def special_deductible_limit_amount_for_public_interest
      ((provisional_income_amount_incl_donations_6_25_rate + capital_stock_end_amount_by_business_month_0_375_rate).quo(2)).floor
    end

    def deductible_amount_for_public_interest
      # 「資本等を有する法人」は「特定公益増進法人等に対する寄附金額」と「同法人等に対する寄附金の特別損失算入限度額」のうち少ない金額
      [donations_public_interest_amount, special_deductible_limit_amount_for_public_interest].min
    end

    def donations_total_amount_excl_foreign_affiliate
      donations_total_amount - donations_foreign_affiliate_amount
    end

    def non_deductible_amount_from_donations_total_amount_excl_foreign_affiliate
      # 「資本等を有する法人」は「一般寄附金の損金算入限度額」も差し引く
      donations_total_amount_excl_foreign_affiliate - deductible_limit_amount_for_general_donations - deductible_amount_for_public_interest - donations_designated_amount
    end

    def total_non_deductible_amount
      non_deductible_amount_from_donations_total_amount_excl_foreign_affiliate + donations_foreign_affiliate_amount + donations_fully_controlled_amount
    end

    def get_business_months
      if fiscal_year == company.founded_fiscal_year.fiscal_year
        founded_month = company.founded_date.month
  
        if founded_month <= company.start_month_of_fiscal_year
          company.start_month_of_fiscal_year - founded_month
        else
          company.start_month_of_fiscal_year - founded_month + 12
        end
      else
        12
      end
    end
  end

  class Appendix1402DetailModel
    attr_accessor :ymd
    attr_accessor :amount
  end
   
end