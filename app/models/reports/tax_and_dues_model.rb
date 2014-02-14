# -*- encoding : utf-8 -*-
#
# $Id: tax_and_dues_model.rb 2477 2011-03-23 15:29:30Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Reports
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
    
    def corporate_tax_at_total
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
