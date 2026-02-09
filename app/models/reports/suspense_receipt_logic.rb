module Reports
  class SuspenseReceiptLogic < BaseLogic

    def build_model
      ret = SuspenseReceiptModel.new
      ret.end_ym = end_ym

      Account.where(is_suspense_receipt_account: true, deleted: false).each do |a|
        sub_accounts = a.sub_accounts.presence || [nil]
        
        sub_accounts.each do |sa|
          amount_at_end = get_amount_at_end_self_only(a.code, sa&.id)
          next if amount_at_end == 0

          detail = build_detail_model(a, sa, amount_at_end)
          ret.details << detail
        end
      end
      
      ret.fill_details(12)
      ret
    end

    private

    def build_detail_model(account, sub_account, amount_at_end)
      detail = SuspenseReceiptDetailModel.new
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
  end
  
  class SuspenseReceiptModel
    attr_accessor :end_ym

    def details
      @details ||= []
    end

    def fill_details(min_count)
      (details.size ... min_count).each do
        details << SuspenseReceiptDetailModel.new
      end
    end

    def income_tax_detail
      @details.find{|d| d.income_tax? }
    end
    
  end
  
  class SuspenseReceiptDetailModel
    include HyaccConst

    attr_accessor :account, :amount_at_end, :branch_id, :company, :end_ym, :end_ymd, :start_ym, :sub_account

    def account_name
      account&.name
    end

    def counterpart_name
      customer.formal_name_on(end_ymd) if account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
    end

    def counterpart_address
      customer.address_on(end_ymd) if account&.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
    end

    def income_tax?
      sub_account.code == TAX_DEDUCTION_TYPE_INCOME_TAX
    end
    
    def note
      if account
        if account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
          ret = get_note(start_ym, end_ym, company.id, account.id, branch_id)
          ret = '誤入金' unless ret
          ret = ret + '　等'
        else
          if sub_account
            "#{sub_account.name}の#{account.name}"
          else
            account.name
          end
        end
      end
    end

    private

    def customer
      @customer ||= Customer.find_by_code(sub_account.code)
    end

    def get_note(ym_from, ym_to, company_id, account_id, branch_id)
      sql = SqlBuilder.new
      sql.append('select note from journal_details jd')
      sql.append('inner join journals jh on (jh.id = jd.journal_id)')
      sql.append('where company_id = ?', company_id)
      sql.append('and branch_id = ?', branch_id) if branch_id.to_i > 0
      sql.append('and ym >= ?', ym_from)
      sql.append('and ym <= ?', ym_to)
      sql.append('and account_id = ?', account_id)
      sql.append('and deleted = ?', false)
      sql.append('order by jd.amount DESC limit 1')
      JournalDetail.find_by_sql(sql.to_a)[0]&.note
    end
  
  end
end
