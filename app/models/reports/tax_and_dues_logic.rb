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
      model.corporate_tax_at_half += net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.corporate_tax_at_half += net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_RECONSTRUCTION_TAX)

      model.corporate_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_CORPORATE_TAX)
      model.corporate_tax_at_full += net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_REGIONAL_CORPORATE_TAX)
      model.corporate_tax_at_full += net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_RECONSTRUCTION_TAX)
      
      model.prefectural_tax_payable_at_start_first = nil
      model.prefectural_tax_payable_at_start_second = corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.prefectural_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)
      model.prefectural_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_PREFECTURAL_TAX)

      model.municipal_inhabitants_tax_payable_at_start_first = nil
      model.municipal_inhabitants_tax_payable_at_start_second = corporate_tax_payable_net_sum_until(CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)
      model.municipal_inhabitants_tax_at_half = net_sum(SETTLEMENT_TYPE_HALF, CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)
      model.municipal_inhabitants_tax_at_full = net_sum(SETTLEMENT_TYPE_FULL, CORPORATE_TAX_TYPE_MUNICIPAL_INHABITANTS_TAX)

      model.business_tax_payable_at_start_first = nil
      model.business_tax_payable_at_start_second = nil
      model.business_tax_at_half = nil
      model.business_tax_at_full = get_corporate_enterprise_tax_amount

      model
    end

    private

    def corporate_tax_payable_net_sum_until(sub_account_id)
      VTax.net_sum_until(start_ym, @corporate_tax_payable.id, sub_account_id)
    end
    
    def net_sum(settlement_type, sub_account_id)
      sum = 0
      
      @corporate_taxes.each do |ct|
      amount = VTax.net_sum(start_ym, end_ym, settlement_type, ct.id, sub_account_id)
        sum = sum.to_i + amount.to_i
      end

      sum
    end
  end

  class TaxAndDuesModel
    attr_accessor :company_name
    attr_accessor :corporate_tax_payable_at_start_first
    attr_accessor :corporate_tax_payable_at_start_second
    attr_accessor :corporate_tax_at_half
    attr_accessor :corporate_tax_at_full
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
    
    def corporate_tax_payable_at_start_total
      return nil unless @corporate_tax_payable_at_start_first or @corporate_tax_payable_at_start_second
      @corporate_tax_payable_at_start_first.to_i + @corporate_tax_payable_at_start_second.to_i
    end
    
    def total_corporate_tax
      return nil unless @corporate_tax_at_half or @corporate_tax_at_full
      @corporate_tax_at_half.to_i + @corporate_tax_at_full.to_i
    end
    
    def prefectural_tax_payable_at_start_total
      return nil unless @prefectural_tax_payable_at_start_first or @prefectural_tax_payable_at_start_second
      @prefectural_tax_payable_at_start_first.to_i + @prefectural_tax_payable_at_start_second.to_i
    end
    
    def prefectural_tax_at_total
      return nil unless @prefectural_tax_at_half or @prefectural_tax_at_full
      @prefectural_tax_at_half.to_i + @prefectural_tax_at_full.to_i
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
      return nil unless @business_tax_payable_at_start_first or @business_tax_payable_at_start_second
      @business_tax_payable_at_start_first.to_i + @business_tax_payable_at_start_second.to_i
    end
    
    def business_tax_at_total
      return nil unless @business_tax_at_half or @business_tax_at_full
      @business_tax_at_half.to_i + @business_tax_at_full.to_i
    end
  end

end
