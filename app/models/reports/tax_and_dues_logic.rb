module Reports
  # 租税公課の納付状況等に関する明細書
  class TaxAndDuesLogic < BaseLogic
    
    def initialize(finder)
      super(finder)
      @corporate_tax_payable = Account.find_by_code(ACCOUNT_CODE_CORPORATE_TAXES_PAYABLE)
      @corporate_taxes = Account.where(is_tax_account: true, dc_type: DC_TYPE_DEBIT, deleted: false)
    end
    
    def build_model
      model = TaxAndDuesModel.new
      model.company_name = Company.find(@finder.company_id).name
      model.corporate_tax_payable_at_start_first = nil
      
      model.corporate_tax_payable_at_start_second = corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.corporate_tax_payable_at_start_second += corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.corporate_tax_payable_at_start_second += corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_RECONSTRUCTION_TAX)
      
      model.corporate_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.regional_corporate_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.reconstruction_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_RECONSTRUCTION_TAX)

      model.corporate_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.regional_corporate_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.reconstruction_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_RECONSTRUCTION_TAX)
      
      model.prefectural_tax_payable_at_start_first = nil
      model.prefectural_tax_payable_at_start_second = corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.prefectural_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.prefectural_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)

      model.municipal_inhabitants_tax_payable_at_start_first = nil
      model.municipal_inhabitants_tax_payable_at_start_second = corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)
      model.municipal_inhabitants_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)
      model.municipal_inhabitants_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)

      # 事業税
      model.business_tax_payable_at_start_first = nil
      model.business_tax_payable_at_start_second = get_corporate_enterprise_tax_net_sum(SETTLEMENT_TYPE_FULL)
      model.business_tax_at_half = get_corporate_enterprise_tax_net_sum(SETTLEMENT_TYPE_HALF)
      model.business_tax_at_full = 0 #事業税を支払った時に処理する仕訳を想定（一般的ではない）

      model
    end

    private

    def corporate_tax_payable_net_sum_until(sub_account_id)
      VTaxAndDues.net_sum_until(start_ym, @corporate_tax_payable.id, sub_account_id)
    end
    
    def net_sum(settlement_type, sub_account_id)
      sum = 0
      
      @corporate_taxes.each do |ct|
        amount = VTaxAndDues.net_sum(start_ym, end_ym, settlement_type, ct.id, sub_account_id)
        sum = sum.to_i + amount.to_i
      end

      sum
    end
  
    def get_corporate_enterprise_tax_net_sum(settlement_type)
      account = Account.find_by_code(ACCOUNT_CODE_TAX_AND_DUES)
      sub_account = account.get_sub_account_by_code(SUB_ACCOUNT_CODE_CORPORATE_ENTERPRISE_TAX)

      VTaxAndDues.net_sum(start_ym, end_ym, settlement_type, account.id, sub_account.id)
    end
  end

  class TaxAndDuesModel
    attr_accessor :company_name
    attr_accessor :corporate_tax_payable_at_start_first
    attr_accessor :corporate_tax_payable_at_start_second
    attr_accessor :corporate_tax_at_half
    attr_accessor :regional_corporate_tax_at_half
    attr_accessor :reconstruction_tax_at_half
    attr_accessor :corporate_tax_at_full
    attr_accessor :regional_corporate_tax_at_full
    attr_accessor :reconstruction_tax_at_full
    attr_accessor :prefectural_tax_payable_at_start_first
    attr_accessor :prefectural_tax_payable_at_start_second
    attr_accessor :prefectural_tax_at_half
    attr_accessor :prefectural_tax_at_full
    attr_accessor :municipal_inhabitants_tax_payable_at_start_first
    attr_accessor :municipal_inhabitants_tax_payable_at_start_second
    attr_accessor :municipal_inhabitants_tax_at_half
    attr_accessor :municipal_inhabitants_tax_at_full
    attr_accessor :business_tax_payable_at_start_first
    attr_accessor :business_tax_payable_at_start_second
    attr_accessor :business_tax_at_half
    attr_accessor :business_tax_at_full
    
    def total_corporate_tax_payable_at_start
      @corporate_tax_payable_at_start_first.to_i + @corporate_tax_payable_at_start_second.to_i
    end

    def total_corporate_tax_at_half
      corporate_tax_at_half + regional_corporate_tax_at_half + reconstruction_tax_at_half
    end

    def total_corporate_tax_at_full
      corporate_tax_at_full + regional_corporate_tax_at_full + reconstruction_tax_at_full
    end

    def total_corporate_tax
      total_corporate_tax_at_half + total_corporate_tax_at_full
    end

    # 法人税及び地方法人税、前前期、損金経理による納付
    def corporate_tax_paid_at_start_first
      corporate_tax_payable_at_start_first
    end

    # 法人税及び地方法人税、前期、損金経理による納付
    def corporate_tax_paid_at_start_second
      corporate_tax_payable_at_start_second
    end

    # 法人税及び地方法人税、当期分、中間、損金経理による納付
    def total_corporate_tax_paid_at_half
      total_corporate_tax_at_half
    end
  
    # 法人税及び地方法人税、当期分、確定、損金経理による納付
    def total_corporate_tax_paid_at_full
      0
    end

    def total_corporate_tax_paid
      total_corporate_tax_payable_at_start + total_corporate_tax_at_half
    end

    def prefectural_tax_paid_at_start_first
      prefectural_tax_payable_at_start_first.to_i
    end

    def prefectural_tax_paid_at_start_second
      prefectural_tax_payable_at_start_second.to_i
    end

    def prefectural_tax_payable_at_start_total
      return nil unless @prefectural_tax_payable_at_start_first or @prefectural_tax_payable_at_start_second
      @prefectural_tax_payable_at_start_first.to_i + @prefectural_tax_payable_at_start_second.to_i
    end
  
    def prefectural_tax_paid_at_half
      prefectural_tax_at_half.to_i
    end

    def prefectural_tax_paid_at_full
      0
    end
    
    def prefectural_tax_at_total
      return nil unless @prefectural_tax_at_half or @prefectural_tax_at_full
      @prefectural_tax_at_half.to_i + @prefectural_tax_at_full.to_i
    end

    def prefectural_tax_paid_at_total
      prefectural_tax_paid_at_start_first + prefectural_tax_paid_at_start_second + prefectural_tax_paid_at_half + prefectural_tax_paid_at_full
    end
    
    def municipal_inhabitants_tax_payable_at_start_total
      return nil unless @municipal_inhabitants_tax_payable_at_start_first or @municipal_inhabitants_tax_payable_at_start_second
      @municipal_inhabitants_tax_payable_at_start_first.to_i + @municipal_inhabitants_tax_payable_at_start_second.to_i
    end
    
    def municipal_inhabitants_tax_at_total
      return nil unless @municipal_inhabitants_tax_at_half or @municipal_inhabitants_tax_at_full
      @municipal_inhabitants_tax_at_half.to_i + @municipal_inhabitants_tax_at_full.to_i  
    end
    
    def business_tax_payable_at_start_total
      business_tax_payable_at_start_first.to_i + business_tax_payable_at_start_second.to_i
    end
    
    def business_tax_at_total
      business_tax_payable_at_start_total + business_tax_at_half.to_i + business_tax_at_full.to_i
    end
  end

end
