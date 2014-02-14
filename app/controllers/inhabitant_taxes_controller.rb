# coding: UTF-8
#
# $Id: inhabitant_taxes_controller.rb 3180 2014-01-18 03:53:23Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class InhabitantTaxesController < Base::BasicMasterController
  available_for :type=>:company_type, :except=>COMPANY_TYPE_PERSONAL
  view_attribute :title => '住民税'
  view_attribute :finder, :class=>InhabitantTaxFinder, :only=>:index
  view_attribute :model, :class=>InhabitantTax
  view_attribute :ym_list, :only=>:index
  
  # CSVフォーマットからモデル登録用にコンバート
  def make_array(csv_array)
    model_array = []
    model_array << csv_array[0]  # 年月
    model_array << csv_array[1]  # employee_id
    model_array << csv_array[2]  # amount
  end
end
