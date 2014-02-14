# -*- encoding : utf-8 -*-
#
# $Id: withheld_tax_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class WithheldTaxFinder < Base::Finder

  attr_accessor :after_deduction
  
  # 初期化
  def initialize( user )
    super( user )
    @ym = Time.new.strftime("%Y%m")
  end
  
  def setup_from_params( params )
    return unless params

    super( params )
    @after_deduction = params[:after_deduction]
  end
  
  def list
    conditions = []
    conditions[0] = ""
    if @ym != ""
      conditions[0] << "apply_start_ym <= ? AND apply_end_ym >= ?"
      conditions << self.ym.to_s
      conditions << self.ym.to_s
    end
    if @after_deduction != "" && @after_deduction.gsub!(/,/, "") != ""
      unless conditions[0].blank?
        conditions[0] << " AND "
      end
      conditions[0] << "pay_range_above <= ? AND pay_range_under > ?"
      conditions << @after_deduction
      conditions << @after_deduction
    end
    
    WithheldTax.find(:all, :conditions=>conditions)
  end
end
