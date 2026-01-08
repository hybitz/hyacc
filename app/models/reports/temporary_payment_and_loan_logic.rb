module Reports
  class TemporaryPaymentAndLoanLogic < BaseLogic

    def build_model
      ret = TemporaryPaymentAndLoanModel.new
      ret.end_ym = end_ym

      temporary_payment_accounts = Account.where(is_temporary_payment_account: true, deleted: false)
      temporary_payment_accounts.each do |a|
        sub_accounts = a.sub_accounts

        if sub_accounts.present?
          sub_accounts.each do |sa|
            amount_at_end = get_amount_at_end_self_only(a.code, sa.id)
            next if amount_at_end == 0

            detail = ret.new_temporary_payment_detail
            detail.account = a
            detail.amount_at_end = amount_at_end
            detail.branch_id = branch_id
            detail.company = company
            detail.end_ym = end_ym
            detail.end_ymd = end_ymd
            detail.start_ym = start_ym
            detail.sub_account = sa
            ret.temporary_payment_details << detail
          end
        else
          amount_at_end = get_amount_at_end_self_only(a.code)
          next if amount_at_end == 0

          detail = ret.new_temporary_payment_detail
          detail.account = a
          detail.amount_at_end = amount_at_end
          detail.branch_id = branch_id
          detail.company = company
          detail.end_ym = end_ym
          detail.end_ymd = end_ymd
          detail.start_ym = start_ym
          ret.temporary_payment_details << detail
        end
      end

      loan_accounts = []
      
      loan_accounts.each do |a|
        sub_accounts = a.sub_accounts
        
        if sub_accounts.present?
          sub_accounts.each do |sa|
            amount_at_end = get_amount_at_end(a.code, sa.id)
            interest_received = get_this_term_debit_amount(ACCOUNT_CODE_INTEREST_RECEIVED, sa.id)
            next if amount_at_end == 0 && interest_received == 0

            detail = ret.new_loan_detail
            detail.account = a
            detail.amount_at_end = amount_at_end
            detail.interest_received = interest_received
            detail.branch_id = branch_id
            detail.company = company
            detail.end_ym = end_ym
            detail.end_ymd = end_ymd
            detail.start_ym = start_ym
            detail.sub_account = sa
            ret.loan_details << detail
          end
        else
          amount_at_end = get_amount_at_end(a.code, nil)
          interest_received = get_this_term_debit_amount(ACCOUNT_CODE_INTEREST_RECEIVED, nil)
          next if amount_at_end == 0 && interest_received == 0

          detail = ret.new_loan_detail
          detail.account = a
          detail.amount_at_end = amount_at_end
          detail.interest_received = interest_received
          detail.branch_id = branch_id
          detail.company = company
          detail.end_ym = end_ym
          detail.end_ymd = end_ymd
          detail.start_ym = start_ym
          ret.loan_details << detail
        end
      end
      
      ret
    end

    private

    def get_amount_at_end_self_only(account_code, sub_account_id = nil)
      a = Account.find_by(code: account_code, deleted: false)
      VMonthlyLedger.net_sum(nil, end_ym, a.id, sub_account_id, branch_id, include_children: false)
    end
  end
  
  class TemporaryPaymentAndLoanModel
    attr_accessor :end_ym, :start_ym

    def temporary_payment_details
      @temporary_payment_details ||= []
    end

    def loan_details
      @loan_details ||= []
    end

    def new_temporary_payment_detail
      TemporaryPaymentDetailModel.new
    end

    def new_loan_detail
      LoanDetailModel.new
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

    attr_accessor :account, :amount_at_end, :interest_received, :branch_id, :company, :end_ym, :end_ymd, :start_ym, :sub_account

    def account_name
      account&.name
    end

    def counterpart_name
      if account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
        customer.formal_name_on(end_ymd) if customer
      elsif sub_account
        sub_account.name
      end
    end

    def counterpart_address
      if account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
        customer.address_on(end_ymd) if customer
      end
    end

    private

    def customer
      @customer ||= Customer.find_by_code(sub_account.code)
    end
  end
end


