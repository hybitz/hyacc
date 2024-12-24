module Reports
  class SuspenseReceiptLogic < BaseLogic

    def build_model
      ret = SuspenseReceiptModel.new
      ret.end_ym = end_ym

      Account.where(is_suspense_receipt_account: true).each do |a|
        sub_accounts = a.sub_accounts
        sub_accounts << nil if sub_accounts.empty?
        
        sub_accounts.each do |sa|
          if sa
            amount_at_end = get_amount_at_end(a.code, sa.id)
          else
            amount_at_end = get_amount_at_end(a.code)
          end
          next if amount_at_end == 0

          detail = ret.new_detail
          detail.end_ymd = end_ymd
          detail.account = a
          detail.sub_account = sa
          detail.amount_at_end = amount_at_end
          ret.details << detail
        end
      end
      
      ret
    end
  end
  
  class SuspenseReceiptModel
    attr_accessor :end_ym

    def details
      @details ||= []
    end

    def new_detail
      SuspenseReceiptDetailModel.new
    end

    def income_tax_detail
      @details.find{|d| d.income_tax? }
    end
    
  end
  
  class SuspenseReceiptDetailModel
    include HyaccConst

    attr_accessor :account, :sub_account, :amount_at_end, :end_ymd
    
    def account_name
      account.try(:name)
    end

    def counterpart_name
      return nil unless account

      if account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
        customer.formal_name_on(end_ymd)
      end
    end

    def counterpart_address
      return nil unless account

      if account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
        customer.address_on(end_ymd)
      end
    end

    def income_tax?
      sub_account.code == SUB_ACCOUNT_CODE_INCOME_TAX
    end
    
    def note
      if account
        if account.sub_account_type == SUB_ACCOUNT_TYPE_CUSTOMER
          '誤入金' # TODO それ以外のケースは？
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
  
  end
end
