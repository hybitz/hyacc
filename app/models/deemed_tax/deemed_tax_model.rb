# -*- encoding : utf-8 -*-
#
# $Id: deemed_tax_model.rb 2475 2011-03-23 15:28:31Z ichy $
# Product: hyacc
# Copyright 2010 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module DeemedTax
  class DeemedTaxModel
    # 会計年度（AR）
    attr_accessor :fiscal_year
    # 事業区分（AR）
    attr_accessor :business_type
    # 課税売上高
    attr_accessor :imposition_sales_amount
    # 課税標準額
    attr_accessor :imposition_base_amount
    # 消費税
    attr_accessor :tax_amount
    # 地方消費税
    attr_accessor :local_tax_amount
    # 納税額
    attr_accessor :total_tax_amount
    # 仕訳金額
    attr_accessor :journal_amount
    
    def initialize
      @imposition_sales_amount = 0
      @imposition_base_amount = 0
      @tax_amount = 0
      @local_tax_amount = 0
      @total_tax_amount = 0
      @journal_amount = 0
    end

    def has_tax_amount
      @total_tax_amount > 0
    end
    
    def is_journal_amount_valid
      @total_tax_amount == @journal_amount
    end
  end
end
