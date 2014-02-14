# -*- encoding : utf-8 -*-
#
# $Id: simple_slip_template_finder.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class SimpleSlipTemplateFinder < Base::Finder
  include HyaccConstants
  
  def list
    SimpleSlipTemplate.paginate(
      :page=>@page > 0 ? @page : 1,
      :conditions=>make_conditions,
      :order=>"remarks",
      :per_page=>@slips_per_page,
      :include=>[:account, :branch])
  end

private
  def make_conditions
    conditions = []
    
    conditions[0] = 'simple_slip_templates.deleted=? '
    conditions << false
    
    if @account_id > 0
      conditions[0] << 'and account_id = ? '
      conditions << @account_id
    end
  
    if @remarks
      conditions[0] << 'and remarks like ? '
      conditions << "%#{@remarks}%"
    end
  
    conditions
  end
end
