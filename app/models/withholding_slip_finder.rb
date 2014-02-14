# -*- encoding : utf-8 -*-
#
# $Id: withholding_slip_finder.rb 3132 2013-08-16 05:46:04Z hiro $
# Product: hyacc
# Copyright 2012 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class WithholdingSlipFinder < Base::Finder
  attr_reader :company_id
  attr_reader :report_type
  attr_reader :report_style
  attr_reader :fiscal_year
  attr_reader :employee_id
  
  def initialize(user)
    super(user)
    @company_id = user.company.id
  end
  
  def setup_from_params( params )
    super(params)
    if params
      @report_type = params[:report_type].to_i
      @report_style = params[:report_style].to_i
      @fiscal_year = params[:fiscal_year].to_i
      @employee_id = params[:employee_id].to_i
    end
  end

end
