module Reports
  class SuspenseReceiptLogic < BaseLogic

    def build_model
      ret = SuspenseReceiptModel.new

      Account.where(is_suspense_receipt_account: true).each do |a|
        sub_accounts = a.sub_accounts.map(&:id)
        sub_accounts << nil if sub_accounts.empty?
        
        sub_accounts.each do |sa_id|
          amount_at_end = get_amount_at_end(a.code, sa_id)
          next if amount_at_end == 0

          detail = ret.new_detail
          detail.account = a
          detail.sub_account = a.sub_accounts.find{|sa| sa.id == sa_id}
          detail.amount_at_end = amount_at_end
          ret.details << detail
        end
      end
      
      ret
    end
  end
  
  class SuspenseReceiptModel
    
    def details
      @details ||= []
    end

    def new_detail
      SuspenseReceiptDetailModel.new
    end
    
  end
  
  class SuspenseReceiptDetailModel
    attr_accessor :account, :sub_account, :amount_at_end
    
    def account_name
      account.try(:name)
    end
    
    def note
      if account
        if sub_account
          "#{sub_account.name}の#{account.name}"
        else
          account.name
        end
      end
    end
  end
end
