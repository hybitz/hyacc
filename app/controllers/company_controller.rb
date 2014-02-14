# -*- encoding : utf-8 -*-
#
# $Id: company_controller.rb 3032 2013-06-21 02:15:09Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
class CompanyController < Base::HyaccController
  layout 'application'
  view_attribute :title=>'会社'

  def index
    id = params[:id]
    id = current_user.company.id unless id
    
    @company = Company.find( id )
    
    # 資本金を算出する
    unless @company.type_of_personal
      @capital = get_capital_stock( @company.fiscal_year )
    end
  end
  
  def edit_business_type
    @company = Company.find( params[:id] )
  end
  
  def update_business_type
    form = params[:company]
    @company = Company.find( form[:id] )
    @company.business_type_id = form[:business_type_id]
    @company.save!
    redirect_to :action=>:index
  end

  def edit_logo_path
    @company = Company.find( params[:id] )
  end
    
  def update_logo_path
    form = params[:company]
    @company = Company.find( form[:id] )
    @company.logo_path = form[:logo_path]
    @company.save!
    redirect_to :action=>:index
  end  
end
