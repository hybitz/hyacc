# -*- encoding : utf-8 -*-
#
# $Id: inhabitant_tax_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InhabitantTaxFinder < Base::Finder
  attr_accessor :year

  # 初期化
  def initialize( user )
    super( user )
    yyyy = Time.new.strftime("%Y").to_i
    yyyymm = Time.new.strftime("%Y%m").to_i
    @year = yyyy + yyyymm/(yyyy.to_s + '06').to_i - 1
  end
  
  def setup_from_params( params )
    return unless params
    super( params )
    @year = params[:year].to_i
  end
  
  def list
    raise HyaccException.new("年は必須です。") if @year == 0

    conditions = []
    conditions[0] = "ym >= ? and ym <= ?"
    conditions << @year.to_s + '06'
    conditions << (@year + 1).to_s + '05'

    InhabitantTax.find(:all, :conditions=>conditions, :order=>"employee_id, ym")
  end
end
