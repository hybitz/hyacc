module Reports
  class TemporaryPaymentAndLoanLogic < BaseLogic

    def build_model
      ret = TemporaryPaymentAndLoanModel.new

      temporary_payment_accounts = Account.where(is_temporary_payment_account: true, deleted: false)
      temporary_payment_accounts.each do |a|
        sub_accounts = a.sub_accounts.presence || [nil]

        sub_accounts.each do |sa|
          amount_at_end = get_amount_at_end_self_only(a.code, sa&.id)
          next if amount_at_end == 0

          ret.build_temporary_payment_detail(a, sa, amount_at_end, branch_id, company, end_ym, end_ymd, start_ym)
        end  
      end

      # TODO: LoanDetailに関する処理を実装する
      
      ret
    end

    private

    def get_amount_at_end_self_only(account_code, sub_account_id = nil)
      a = Account.find_by(code: account_code, deleted: false)
      VMonthlyLedger.net_sum(nil, end_ym, a.id, sub_account_id, branch_id, include_children: false)
    end
  end
  
  class TemporaryPaymentAndLoanModel

    def temporary_payment_details
      @temporary_payment_details ||= []
    end

    def loan_details
      @loan_details ||= []
    end

    def build_temporary_payment_detail(account, sub_account, amount_at_end, branch_id, company, end_ym, end_ymd, start_ym)
      detail = TemporaryPaymentDetailModel.new
      detail.account = account
      detail.amount_at_end = amount_at_end
      detail.branch_id = branch_id
      detail.company = company
      detail.end_ym = end_ym
      detail.end_ymd = end_ymd
      detail.start_ym = start_ym
      detail.sub_account = sub_account
      temporary_payment_details << detail
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
  
  # TODO: LoanDetailModelクラスを実装する
end


