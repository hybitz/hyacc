module Reports
  class SavingsLogic < BaseLogic

    def build_model
      ret = SavingsModel.new

      company.bank_accounts.where(financial_account_type: [FINANCIAL_ACCOUNT_TYPE_SAVING, FINANCIAL_ACCOUNT_TYPE_CHECKING]).each do |ba|
        amount = get_amount_at_end(ACCOUNT_CODE_ORDINARY_DIPOSIT, ba.id)
        next if amount.zero?

        detail = SavingsDetailModel.new
        detail.bank_name = ba.bank.name
        detail.bank_office_name = ba.bank_office.name
        case ba.financial_account_type
        when FINANCIAL_ACCOUNT_TYPE_SAVING
          detail.financial_account_type_name = '普通'
        when FINANCIAL_ACCOUNT_TYPE_CHECKING
          detail.financial_account_type_name = '当座'
        end
        detail.bank_account_code = ba.code
        detail.bank_account = ba
        detail.amount = amount
        ret.add_detail(detail)
      end
      
      ret.fill_details(10)
      ret
    end

  end

  class SavingsModel
    attr_accessor :details

    def initialize
      self.details = []
    end

    def add_detail(detail)
      self.details << detail
    end

    def fill_details(min_count)
      (details.size ... min_count).each do
        add_detail(SavingsDetailModel.new)
      end
    end

    def total_amount
      self.details.inject(0) do |sum, d|
        sum += d.amount.to_i
      end
    end
    
  end
  
  class SavingsDetailModel
    attr_accessor :bank_name
    attr_accessor :bank_office_name
    attr_accessor :financial_account_type_name
    attr_accessor :bank_account_code
    attr_accessor :bank_account
    attr_accessor :amount
  end

end
