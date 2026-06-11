module Reports
  class TemporaryPaymentAndLoanLogic < BaseLogic
    LOAN_COUNTERPARTY_ACCOUNT_GROUPS = [
      {
        sub_account_type: SUB_ACCOUNT_TYPE_EMPLOYEE,
        short_term_code: ACCOUNT_CODE_SHORT_TERM_LOAN_EMPLOYEE,
        long_term_code: ACCOUNT_CODE_LONG_TERM_LOAN_EMPLOYEE,
        interest_code: ACCOUNT_CODE_INTEREST_RECEIVED_LOAN_EMPLOYEE
      },
      {
        sub_account_type: SUB_ACCOUNT_TYPE_BRANCH,
        short_term_code: ACCOUNT_CODE_SHORT_TERM_LOAN_BRANCH,
        long_term_code: ACCOUNT_CODE_LONG_TERM_LOAN_BRANCH,
        interest_code: ACCOUNT_CODE_INTEREST_RECEIVED_LOAN_BRANCH
      },
      {
        sub_account_type: SUB_ACCOUNT_TYPE_CUSTOMER,
        short_term_code: ACCOUNT_CODE_SHORT_TERM_LOAN_CUSTOMER,
        long_term_code: ACCOUNT_CODE_LONG_TERM_LOAN_CUSTOMER,
        interest_code: ACCOUNT_CODE_INTEREST_RECEIVED_LOAN_CUSTOMER
      }
    ]

    PARENT_LOAN_ACCOUNT_CODES = [
      ACCOUNT_CODE_SHORT_TERM_LOAN,
      ACCOUNT_CODE_LONG_TERM_LOAN
    ]

    def build_model
      ret = TemporaryPaymentAndLoanModel.new

      temporary_payment_accounts = Account.where(is_temporary_payment_account: true, deleted: false)
      temporary_payment_accounts.each do |a|
        sub_accounts = a.sub_accounts.presence || [nil]

        sub_accounts.each do |sa|
          amount_at_end = get_amount_at_end_self_only(a.code, sa&.id)
          next if amount_at_end == 0

          detail = build_temporary_payment_detail(a, sa, amount_at_end)
          ret.temporary_payment_details << detail
        end
      end

      build_loan_details(ret)

      ret.fill_loan_details(7)

      ret
    end

    private

    def build_temporary_payment_detail(account, sub_account, amount_at_end)
      detail = TemporaryPaymentDetailModel.new
      detail.account = account
      detail.amount_at_end = amount_at_end
      detail.branch_id = branch_id
      detail.company = company
      detail.end_ym = end_ym
      detail.end_ymd = end_ymd
      detail.start_ym = start_ym
      detail.sub_account = sub_account
      detail
    end

    def build_loan_details(ret)
      LOAN_COUNTERPARTY_ACCOUNT_GROUPS.each do |group|
        account = Account.find_by_code(group[:short_term_code])
        sub_accounts = account.sub_accounts.presence || []

        sub_accounts.each do |sa|
          amount_at_end = loan_amount_at_end(group, sa.id)
          detail = build_loan_detail(group, sa, amount_at_end)
          next if detail.amount_at_end == 0 && detail.interest_in_period == 0

          ret.loan_details << detail
        end
      end

      amount_at_end = PARENT_LOAN_ACCOUNT_CODES.sum { |code| get_amount_at_end_self_only(code, nil) }
      if amount_at_end != 0
        detail = build_loan_parent_detail(PARENT_LOAN_ACCOUNT_CODES.first, amount_at_end)
        ret.loan_details << detail
      end
    end

    def build_loan_detail(group, sub_account, amount_at_end)
      detail = LoanDetailModel.new
      detail.sub_account_type = group[:sub_account_type]
      detail.sub_account = sub_account
      detail.amount_at_end = amount_at_end
      detail.interest_in_period = loan_interest_in_period(group, sub_account.id)
      detail.end_ymd = end_ymd
      detail
    end

    def build_loan_parent_detail(parent_code, amount_at_end)
      detail = LoanDetailModel.new
      detail.parent_account_code = parent_code
      detail.amount_at_end = amount_at_end
      detail.interest_in_period = nil
      detail.end_ymd = end_ymd
      detail
    end

    def loan_amount_at_end(group, sub_account_id)
      get_amount_at_end_self_only(group[:short_term_code], sub_account_id) +
        get_amount_at_end_self_only(group[:long_term_code], sub_account_id)
    end

    def loan_interest_in_period(group, sub_account_id)
      get_this_term_credit_amount(group[:interest_code], sub_account_id)
    end

  end

  class TemporaryPaymentAndLoanModel

    def temporary_payment_details
      @temporary_payment_details ||= []
    end

    def loan_details
      @loan_details ||= []
    end

    def fill_loan_details(min_count)
      target = [loan_details.size, min_count].max
      (loan_details.size ... target).each do
        loan_details << LoanDetailModel.new
      end
    end

    def loan_total_amount_at_end
      loan_details.sum { |d| d.amount_at_end.to_i }
    end

    def loan_total_interest_in_period
      loan_details.sum { |d| d.interest_in_period.to_i }
    end

  end

  class TemporaryPaymentDetailModel
    include HyaccConst

    attr_accessor :account, :amount_at_end, :branch_id, :company, :end_ym, :end_ymd, :start_ym, :sub_account

    def account_name
      account.present? ? '仮払金' : nil
    end

    def counterpart_name
      customer.formal_name_on(end_ymd) if account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
    end

    def counterpart_address
      customer.address_on(end_ymd) if account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
    end

    def note
      return unless account

      if account.sub_account_type == SUB_ACCOUNT_TYPE_EMPLOYEE
        return "#{sub_account.name}の#{account.name}"
      end

      sub_account_id = sub_account&.id
      ret = get_note(start_ym, end_ym, company.id, account.id, branch_id, sub_account_id)

      if ret.present?
        return "#{ret}　等"
      end

      if [account.code, account.parent&.code].include?(ACCOUNT_CODE_TEMPORARY_PAYMENT)
        '誤出金　等'
      else
        account.name
      end
    end

    private

    def customer
      @customer ||= Customer.find_by_code(sub_account.code)
    end

    def get_note(ym_from, ym_to, company_id, account_id, branch_id, sub_account_id = nil)
      sql = SqlBuilder.new
      sql.append('select note from journal_details jd')
      sql.append('inner join journals jh on (jh.id = jd.journal_id)')
      sql.append('where company_id = ?', company_id)
      sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
      sql.append('and ym >= ?', ym_from)
      sql.append('and ym <= ?', ym_to)
      sql.append('and account_id = ?', account_id)
      sql.append('and sub_account_id = ?', sub_account_id) if sub_account_id.to_i > 0
      sql.append('and deleted = ?', false)
      sql.append('order by jd.amount DESC limit 1')
      result = JournalDetail.find_by_sql(sql.to_a)[0]&.note
    end
  end

  class LoanDetailModel
    include HyaccConst

    attr_accessor :sub_account_type, :sub_account, :amount_at_end, :interest_in_period
    attr_accessor :parent_account_code, :end_ymd

    def parent_only?
      parent_account_code.present?
    end

    def registration_number
      return unless sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER

      sub_account.enterprise_number
    end

    def counterpart_name
      return if parent_only?

      case sub_account_type
      when SUB_ACCOUNT_TYPE_EMPLOYEE
        sub_account.fullname
      when SUB_ACCOUNT_TYPE_BRANCH
        sub_account.formal_name.presence || sub_account.name
      when SUB_ACCOUNT_TYPE_CUSTOMER
        sub_account.formal_name_on(end_ymd)
      end
    end

    def counterpart_address
      return if parent_only?

      case sub_account_type
      when SUB_ACCOUNT_TYPE_EMPLOYEE
        sub_account.address_on(end_ymd)
      when SUB_ACCOUNT_TYPE_CUSTOMER
        sub_account.address_on(end_ymd)
      end
    end

    def counterpart_relation
      return if parent_only?

      case sub_account_type
      when SUB_ACCOUNT_TYPE_EMPLOYEE
        employee_counterpart_relation
      when SUB_ACCOUNT_TYPE_CUSTOMER
        customer_counterpart_relation
      end
    end

    # TODO 利率を取得する
    def interest_rate
      nil
    end

    # TODO 担保の内容を取得する
    def collateral
      nil
    end

    private

    def employee_counterpart_relation
      labels = []
      labels << '役員' if sub_account.executive?
      if sub_account.relationship_to_representative.present?
        labels << "代表者との関係：#{sub_account.relationship_to_representative}"
      end
      labels.presence&.join('・')
    end

    def customer_counterpart_relation
      labels = []
      labels << '株主' if sub_account.is_shareholder?
      labels << '関係会社' if sub_account.is_related_company?
      labels.presence&.join('・')
    end
  end
end
