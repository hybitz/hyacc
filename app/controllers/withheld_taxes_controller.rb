# coding: UTF-8
#
# $Id: withheld_taxes_controller.rb 3363 2014-02-07 08:20:26Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class WithheldTaxesController < Base::BasicMasterController
  available_for :type=>:company_type, :except=>COMPANY_TYPE_PERSONAL
  view_attribute :finder, :class=>WithheldTaxFinder, :only=>:index
  view_attribute :model, :class=>WithheldTax
  
  def edit
    @data = WithheldTax.find(params[:id])
  end
end
